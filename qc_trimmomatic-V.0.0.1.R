#!/usr/bin/env Rscript

trimmomatic_dir <- paste('/dados/programas/bioinfo/Trimmomatic/')
trimmomatic <- paste(trimmomatic_dir, 'trimmomatic.jar', sep = "")
########################################
### LOADING PACKAGES
########################################

suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("parallel"))


########################################
### SETING PARAMETERS
########################################
# specify our desired options in a list
# by default OptionParser will add an help option equivalent to
# make_option(c("-h", "--help"), action="store_true", default=FALSE,
# help="Show this help message and exit")
option_list <- list(
  make_option(c("-f", "--file"), type = "character", default = "samples.txt",
              help = "The filename of the sample file [default %default]",
              dest = "samplesFile"),
  make_option(c("-d", "--directory"), type = "character", default = "00-Fastq",
              help = "Directory where the raw sequence data is stored [default %default]",
              dest = "Raw_Folder"),
  make_option(c("-o", "--output"), type = "character", default = "01-trimmomatic",
              help = "output folder [default %default]",
              dest = "output"),
  make_option(c("-p", "--processors"), type = "integer", default = 8,
              help = "number of processors to use [default %default]",
              dest = "procs"),
  make_option(c("-a", "--adapters"), type  = 'character', default = 'TruSeq2-PE.fa',
              help = "Directory where the adapter data is stored [default %default]",
              dest = "adapters"),
  make_option(c('-q', '--quality'), type = 'integer', default = 15,
              help = 'Quality score to use during trimming [default %default]',
              dest = 'qual'),
  make_option(c("-m", "--miniumumLength"), type="integer", default=70,
              help="Discard reads less then minimum length [default %default]",
              dest="minL")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list = option_list, description =  paste('Authors: OLIVEIRA, H.C. & CANTAO, M.E. Version: 0.0.1', 'E-mail: hanielcedraz@gmail.com', sep = "\n", collapse = '\n')))


paste('##------', 'Analysis started on', date(), '------##')

paste('version: 0.0.1')

########################################
### PERFORMING QC ANALISYS
########################################

## final preprocess file are linked (from Clean_Folder) to this folder
if (detectCores() < opt$procs){
  write(paste("number of cores specified (", opt$procs,") is greater than the number of cores available (",detectCores(),")",sep=" "),stdout()) 
  paste('Using ', detectCores(), 'threads')
}

if ( !file.exists(opt$samplesFile) ) {
  write(paste("Sample file",opt$samplesFile,"does not exist\n"), stderr())
  stop()
}

report_folder <- 'report_QC_temp'
if(!file.exists(file.path(report_folder))) dir.create(file.path(report_folder), recursive = TRUE, showWarnings = FALSE)



trimmomatic.function <- function(){
  targets <- read.table(opt$samplesFile, header = F, as.is = T)
  for (i in 1:nrow(targets)){
  Final_Folder <- opt$output
  if(!file.exists(file.path(Final_Folder))) dir.create(file.path(Final_Folder), recursive = TRUE, showWarnings = FALSE)
  input_read1 <- paste(opt$Raw_Folder, '/', targets[i,2], sep = "")
  input_read2 <- paste(opt$Raw_Folder, '/', targets[i,3], sep = "")
  output_PE1 <- paste(opt$output, '/', targets[i,1], '_',
                      'trim_PE1.fastq.gz', sep = "")
  output_PE2 <- paste(opt$output, '/', targets[i,1], '_',
                      'trim_PE2.fastq.gz', sep = "")
  output_SE1 <- paste(opt$output, '/', targets[i,1], '_',
                     'trim_SE1.fastq.gz', sep = "")
  output_SE2 <- paste(opt$output, '/', targets[i,1], '_',
                     'trim_SE2.fastq.gz', sep = "")
  summary <- paste('-summary ', report_folder, '/', targets[i,1], '_', 'statsSummaryFile.txt', sep = "")
  adapter <- paste('ILLUMINACLIP:', trimmomatic_dir, 'adapters', '/', opt$adapters, ':2:30:10', sep = "")
  minL <- paste('MINLEN:', opt$minL, sep = "")
  procs <- ifelse(detectCores() < opt$procs, detectCores(), paste( opt$procs))
  qual <- paste('SLIDINGWINDOW:4:', opt$qual, sep = '')
argments = c('-jar', trimmomatic, 'PE', '-threads ', procs, input_read1, input_read2, output_PE1, output_SE1, output_PE2, output_SE2, adapter, 'LEADING:5', 'TRAILING:5', qual, minL, summary)

system2('java', args = argments)
  }
}
res_final <- trimmomatic.function()


samples <- read.table(opt$samplesFile, header = F, as.is = T)
report_sample <- array(dim = 0)
for (i in samples[,1]) {
  report_sample[i] <- read.table(paste(report_folder, '/', i, '_', 'statsSummaryFile.txt', sep = ""), header = F, as.is = T, sep = ':', row.names = 1);
  report_sample <- as.data.frame(report_sample)
}


trans_report <- t(report_sample); report_final <- data.frame(Samples = rownames(trans_report), trans_report[,1:9]); colnames(report_final) <- c('Samples', 'Input_Read_Pairs', 'Pairs_Reads', 'Pairs_Read_Percent', 'Forward_Only_Surviving_Reads', 'Forward_Only_Surviving_Read_Percent', 'Reverse_Only_Surviving_Reads', 'Reverse_Only_Surviving_Read_Percent', 'Dropped_Reads', 'Dropped_Read_Percent')

write.table(report_final, file = 'qc_report_trimmomatic.txt', sep = "\t", row.names = FALSE, col.names = TRUE, quote = F)


#Delete report folder
unlink(report_folder, recursive = TRUE)


paste('##------', 'Analysis finished on', date(), '------##')


