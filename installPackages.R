#!/usr/bin/env Rscript 


Install_Multiples_Packages <- function(packages) {
  pack <- packages[!(packages %in% installed.packages()[,'Package'])];
  if (length(pack)) {
    install.packages(pack, repos = 'https://cran.rstudio.com/', Ncpus = 8)
  }
  
  for (package_i in packages) {
    suppressPackageStartupMessages(library(package_i, character.only = TRUE, quietly = TRUE))
  }
  
}

Install_Multiples_Packages(c("optparse", "parallel", "tools", "dplyr", "data.table", "glue", "devtools"))


if (!"baqcomPackage" %in% installed.packages()[,'Package']) {
  devtools::install_github(repo = "git@github.com:hanielcedraz/baqcomPackage.git", upgrade = "never", quiet = TRUE, force = TRUE)
  suppressPackageStartupMessages(library(baqcomPackage))
}


newPackages <- c("optparse", "parallel", "tools", "dplyr", "data.table", "glue", "devtools", "baqcomPackage")
newInstalledPackages <- newPackages[(newPackages %in% installed.packages()[,'Package'])];

if (length(newInstalledPackages) == 8) {
  write(paste("All packages installed successfully."), stdout())
  
} else if (length(newInstalledPackages) < 8) {
  write(paste("Could not install", paste0(newInstalledPackages, collapse = ", "), "-", "Please install it manually."), stdout())
}

