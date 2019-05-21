#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("tools"))
suppressPackageStartupMessages(library("parallel"))
suppressPackageStartupMessages(library("optparse"))

option_list <- list(
    make_option(c("-f", "--file"), type="character", default="samples.txt",
                help="The filename of the sample file [default %default]",
                dest="samplesFile"),
    make_option(c("-c", "--column"), type="character", default="SAMPLE_ID",
                help="Column name from the sample sheet to use as read folder names [default %default]",
                dest="samplesColumn"),
    make_option(c("-b", "--mappingFolder"), type="character", default='02-MappedReads',
                help="Directory where to store the mapping results [default %default]",
                dest="mappingFolder"),
    make_option(c('-E', '--countFolder'), type = 'character', default = '04-GeneCounts',
                help = 'Folder that contains fasta file genome [default %default]',
                dest = 'countsFolder'),
    make_option(c('-s', '--stranded'), type = 'character', default = 'no',
                help = 'Select the output according to the strandedness of your data. options: no, yes and reverse [default %default]',
                dest = 'stranded')
    
)
# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list = option_list, description =  paste('Authors: OLIVEIRA, H.C. & CANTAO, M.E.', 'E-mail: hanielcedraz@gmail.com', sep = "\n", collapse = '\n')))


loadSamplesFile <- function(file, reads_folder, column){
    ## debug
    file = opt$samplesFile; reads_folder = opt$inputFolder; column = opt$samplesColumn
    ##
    if (!file.exists(file) ) {
        write(paste("Sample file",file,"does not exist\n"), stderr())
        stop()
    }    
    ### column SAMPLE_ID should be the sample name
    ### rows can be commented out with #
    targets <- read.table(file,sep="",header=TRUE,as.is=TRUE)
    if( !all(c("SAMPLE_ID", "Read_1", "Read_2") %in% colnames(targets)) ){
        write(paste("Expecting the three columns SAMPLE_ID, Read_1 and Read_2 in samples file (tab-delimited)\n"), stderr())
        stop()
    }
    for (i in seq.int(nrow(targets$SAMPLE_ID))){
        if (targets[i, column]){
            ext <- unique(file_ext(dir(file.path(reads_folder,targets[i,column]),pattern="gz")))
            if (length(ext) == 0){
                write(paste("Cannot locate fastq or sff file in folder",targets[i,column],"\n"), stderr())
                stop()
            }
            # targets$type[i] <- paste(ext,sep="/")
        }
        else {
            ext <- file_ext(grep("gz", dir(file.path(reads_folder,targets[i, column])), value = TRUE))
            if (length(ext) == 0){
                write(paste(targets[i,column],"is not a gz file\n"), stderr())
                stop()
            }
            
        }
    }
    write(paste("samples sheet contains", nrow(targets), "samples to process",sep=" "),stdout())    
    return(targets)    
}

samples <- loadSamplesFile(opt$samplesFile, opt$inputFolder, opt$samplesColumn)

mapping_Folder <- opt$mappingFolder


# Creating GeneCounts folder and preparing files
if(casefold(opt$stranded, upper = FALSE) == 'no'){
    opt$stranded <- 2
}else if(casefold(opt$stranded, upper = FALSE) == 'yes'){
    opt$stranded  <- 3
}else if(casefold(opt$stranded, upper = FALSE) == 'reverse'){
    opt$stranded  <- 4
}

if(!file.exists(paste0(mapping_Folder, '/', samples[1,1],'_STAR_ReadsPerGene.out.tab'))){
    write(paste('Counts file was not generated because mapping step is running without gtf files'), stderr())
} else{ 
    counts_Folder <- opt$countsFolder
    if(!file.exists(file.path(counts_Folder))){ dir.create(file.path(counts_Folder), recursive = TRUE, showWarnings = FALSE)}
    system(paste('for i in $(ls ', opt$mappingFolder, '/); ', 'do a=`basename $i`;  b=`echo $a | cut -d "_" -f1`; cat ', opt$mappingFolder, '/', '$b"_STAR_ReadsPerGene.out.tab" ', '| ', 'awk ','\'','{', 'print $1"\t"', '$', opt$stranded, '}','\'', ' >', ' ', counts_Folder, '/', '"$b"_ReadsPerGene.counts; done', sep = ''), intern = FALSE)
}