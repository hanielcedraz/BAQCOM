#!/usr/bin/env Rscript 


Install_Multiples_Packages <- function(packages) {
  pack <- packages[!(packages %in% installed.packages()[,'Package'])];
  if (length(pack)) {
    install.packages(pack, repos = 'https://cran.rstudio.com/')
  }

  for (package_i in packages) {
    suppressPackageStartupMessages(library(package_i, character.only = TRUE, quietly = TRUE))
    }

}

Install_And_Load(c('optparse', 'parallel', "tools"))


