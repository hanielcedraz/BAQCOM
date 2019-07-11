#!/usr/bin/env Rscript 


Install_And_Load <- function(packages) {
    k <- packages[!(packages %in% installed.packages()[,'Package'])];
    if(length(k))
    {install.packages(k, repos='https://cran.rstudio.com/');}
    
    for(package_name in packages)
    {library(package_name,character.only=TRUE, quietly = TRUE);}
}
Install_And_Load(c('optparse', 'parallel'))
