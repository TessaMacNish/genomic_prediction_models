# Genomic Prediction Models
This repository contains examples of code used in single nucleotide polymorphisms (SNP)- and haplotype-based genomic prediction. 

The models shown are:

1) Genomic Best Linear Unbiased Prediction (GBLUP) in the file GBLUP.R, using the R package rrBLUP version 4.6.1 (Endelman, 2011)
2) Random Forest (RF) in the file RF.R, using the R package ranger version 0.14.1 (Wright & Ziegler, 2017)
3) eXtreme Gradient Boosting (XGBoost) in the file XGBoost.R, using the R package xgboost version 1.7.11.1 (Chen & Guestrin, 2016)

Chen, T., & Guestrin, C. (2016). XGBoost: A scalable tree boosting system. Proceedings of the 22nd ACM SIGKDD International Conference on Knowledge Discovery and Data Mining, 13-17-, 785–794. https://doi.org/10.1145/2939672.2939785

Endelman, J. B. (2011). Ridge regression and other kernels for genomic selection with R package rrBLUP. Plant Breeding, 4(3), 250–255. https://doi.org/10.3835/plantgenome2011.08.0024

Wright, M. N., & Ziegler, A. (2017). ranger: A fast implementation of random forests for high dimensional data in C++ and R. Journal of Statistical Software, 77(1), 1–17. https://doi.org/10.18637/jss.v077.i01
