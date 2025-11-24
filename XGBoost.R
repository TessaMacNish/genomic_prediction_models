#Load package
library(xgboost)
#Load genotype
XGBoost_0.6_10_2 <- read.csv("ep0.6_MGmin10_minFreq2_format3.csv", header = TRUE, row.names = 1)
#Load phenotype 
Pheno <- read.table("GSTP013.pheno.nospace.txt", header = TRUE, row.names = 1)
#Load covariate
Covar <-read.csv("GSTP013_covariate.csv", header = TRUE)
rownames(Covar) <- rownames(XGBoost_0.6_10_2)
FT_ID <- read.csv("FT_ID.csv", header = TRUE, row.names = 1)
FT_ID$x <- paste0(FT_ID$x, "_", FT_ID$x)
rownames(Pheno)  <- paste0(rownames(Pheno), "_", rownames(Pheno))
Pheno_FT <- Pheno[, 1, drop = FALSE]
Pheno_FT <- Pheno_FT[rownames(Pheno_FT) %in% FT_ID$x, , drop = FALSE]
XGBoost_0.6_10_2 <- XGBoost_0.6_10_2[rownames(XGBoost_0.6_10_2) %in% FT_ID$x, ]
XGBoost_0.6_10_2_FT <- XGBoost_0.6_10_2[rownames(XGBoost_0.6_10_2) %in% FT_ID$x, ]
Covar_FT <- Covar[rownames(Covar) %in% FT_ID$x, ]
Covar_FT_onehot <- model.matrix(~ . -1, data = Covar_FT) #one-hot encode the categorical variables
XGBoost_0.6_10_2_FT <- cbind(XGBoost_0.6_10_2_FT, Covar_FT_onehot)
##Split into training and test population with 20% for testing and 80% for training
set.seed(222)
#x
ind <- sample(2, nrow(XGBoost_0.6_10_2_FT), replace = TRUE, prob = c(0.8, 0.2))
XGBoost_0.6_10_2_FT_train <- XGBoost_0.6_10_2_FT[ind==1,]
XGBoost_0.6_10_2_FT_test <- XGBoost_0.6_10_2_FT[ind==2,]
#y
Pheno_FT_train <- Pheno_FT[rownames(XGBoost_0.6_10_2_FT_train), , drop = FALSE]
Pheno_FT_train <- Pheno_FT_train[[1]]
Pheno_FT_test <- Pheno_FT[rownames(XGBoost_0.6_10_2_FT_test), , drop = FALSE]
Pheno_FT_test <- Pheno_FT_test[[1]]
# Convert predictors to matrix
train_matrix <- as.matrix(XGBoost_0.6_10_2_FT_train)
test_matrix <- as.matrix(XGBoost_0.6_10_2_FT_test)
# Create DMatrix objects
dtrain <- xgb.DMatrix(data = train_matrix, label = Pheno_FT_train)
dtest <- xgb.DMatrix(data = test_matrix, label = Pheno_FT_test)
#Set parameters
params <- list(
  booster = "gbtree",
  objective = "reg:squarederror",  # use "reg:logistic" for binary
  eval_metric = "rmse"
)
#Train model
xgb_model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 500,                  # number of boosting iterations
  watchlist = list(train = dtrain, eval = dtest),
  early_stopping_rounds = 10,
  print_every_n = 10
)
# Run predictions
predictions_FT <- predict(xgb_model, dtest)
#MAE (Mean Absolute Error)
library(Metrics)
Test_MAE <- mae(Pheno_FT_test, predictions_FT)
#Calculate RMSE (Root Mean Square Error)
test_rmse <- rmse(Pheno_FT_test, predictions_FT)
#Calculate variable importance 
variable_importance_FT <- xgb.importance(model = xgb_model)
# Calculate Pearson's correlation coefficient
test_correlation <- cor(predictions_FT, Pheno_FT_test, method = "pearson")
