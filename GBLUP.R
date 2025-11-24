library(rrBLUP)
#Load genotype
GBLUP_0.6_10_2 <- read.csv("ep0.6_MGmin10_minFreq2_format5.csv", header = TRUE, row.names = 1)
#Load phenotype 
Pheno <- read.table("GSTP013.pheno.nospace.txt", header = TRUE, row.names = 1)
#Load covariate
Covar <-read.csv("GSTP013_covariate.csv", header = TRUE)
rownames(Covar) <- rownames(GBLUP_0.6_10_2)

FT_ID <- read.csv("FT_ID.csv", header = TRUE, row.names = 1)
FT_ID$x <- paste0(FT_ID$x, "_", FT_ID$x)
rownames(Pheno)  <- paste0(rownames(Pheno), "_", rownames(Pheno))
Pheno_FT <- Pheno[, 1, drop = FALSE]
Pheno_FT <- Pheno_FT[rownames(Pheno_FT) %in% FT_ID$x, , drop = FALSE]
GBLUP_0.6_10_2 <- GBLUP_0.6_10_2[rownames(GBLUP_0.6_10_2) %in% FT_ID$x, ]
GBLUP_0.6_10_2_FT <- GBLUP_0.6_10_2[rownames(GBLUP_0.6_10_2) %in% FT_ID$x, ]
Covar_FT <- Covar[rownames(Covar) %in% FT_ID$x, ]
# Combine phenotype and covariates
pheno_gblup <- data.frame(gid = rownames(Pheno_FT), trait = Pheno_FT[[1]], Covar_FT)
# Compute additive relationship matrix (VanRaden method)
K <- A.mat(GBLUP_0.6_10_2_FT)
# Set testing individuals (mask their phenotype)
set.seed(222)
ind <- sample(2, nrow(pheno_gblup), replace = TRUE, prob = c(0.8, 0.2))
pheno_gblup$trait[ind == 2] <- NA
# Fit GBLUP model
rr_model <- kin.blup(data = pheno_gblup, geno = "gid", pheno = "trait", K = K, fixed = c("Group", "Country") )
#Calculate MAE (Mean Absolute Error)
library(Metrics)
Test_MAE <- mae(Pheno_FT_test, predictions_FT)
#Calculate RMSE (Root Mean Square Error)
test_rmse <- rmse(Pheno_FT_test, predictions_FT)
# Calculate Pearson's correlation coefficient
test_correlation <- cor(predictions_FT, Pheno_FT_test, method = "pearson")
