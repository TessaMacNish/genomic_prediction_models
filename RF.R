##Load package
library(ranger)
#Load genotype
RF _0.6_10_2 <- read.csv("ep0.6_MGmin10_minFreq2_format3.csv", header = TRUE, row.names = 1)
#Load phenotype 
Pheno <- read.table("GSTP013.pheno.nospace.txt", header = TRUE, row.names = 1)
#Load covariate
Covar <-read.csv("GSTP013_covariate.csv", header = TRUE)
rownames(Covar) <- rownames(RF _0.6_10_2)
FT_ID <- read.csv("FT_ID_w_outliers.csv", header = TRUE, row.names = 1)
FT_ID$x <- paste0(FT_ID$x, "_", FT_ID$x)
rownames(Pheno)  <- paste0(rownames(Pheno), "_", rownames(Pheno))
Pheno_FT <- Pheno[, 1, drop = FALSE]
Pheno_FT <- Pheno_FT[rownames(Pheno_FT) %in% FT_ID$x, , drop = FALSE]
RF_pheno_covar_SNP <- RF_pheno_covar_SNP[rownames(RF_pheno_covar_SNP) %in% FT_ID$x, ]
RF_pheno_covar_SNP_FT <- RF_pheno_covar_SNP[rownames(RF_pheno_covar_SNP) %in% FT_ID$x, ]
Covar_FT <- Covar[rownames(Covar) %in% FT_ID$x, ]
RF_pheno_covar_SNP_FT <- cbind(RF_pheno_covar_SNP_FT, Covar_FT)
##Split into training and test population with 20% for testing and 80% for training
set.seed(222)
#x
ind <- sample(2, nrow(RF_pheno_covar_SNP_FT), replace = TRUE, prob = c(0.8, 0.2))
RF_pheno_covar_SNP_FT_train <- RF_pheno_covar_SNP_FT[ind==1,]
RF_pheno_covar_SNP_FT_test <- RF_pheno_covar_SNP_FT[ind==2,]
#y
Pheno_FT_train <- Pheno_FT[rownames(RF_pheno_covar_SNP_FT_train), , drop = FALSE]
Pheno_FT_train <- Pheno_FT_train[[1]]
Pheno_FT_test <- Pheno_FT[rownames(RF_pheno_covar_SNP_FT_test), , drop = FALSE]
Pheno_FT_test <- Pheno_FT_test[[1]]
x_train <- data.matrix(RF_pheno_covar_SNP_FT_train) 
x_test  <- data.matrix(RF_pheno_covar_SNP_FT_test)
y_train <- Pheno_FT_train                              
#Run RF using ranger
rf_model_FT <- ranger(
  x = x_train,
  y = y_train,
  importance = "permutation",
  seed = 222
)
# Predict on test set
predictions_FT <- predict(rf_model_FT, data = x_test)$predictions
#Calculate MAE (Mean Absolute Error)
library(Metrics)
Test_MAE <- mae(Pheno_FT_test, predictions_FT)
#Calculate RMSE (Root Mean Square Error)
test_rmse <- rmse(Pheno_FT_test, predictions_FT)
# Calculate Pearson's correlation coefficient
test_correlation <- cor(predictions_FT, Pheno_FT_test, method = "pearson")
