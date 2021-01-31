#!/usr/bin/env Rscript


suppressPackageStartupMessages(library("tools"))
suppressPackageStartupMessages(library("parallel"))
suppressPackageStartupMessages(library("optparse"))

option_list <- list(
    make_option(c("-f", "--file"), type = "character", default = "samples.txt",
                help = "The filename of the sample file [default %default]",
                dest = "samplesFile"),
    make_option(c("-b", "--format"), type = "character", default = "sam",
                help = "type of alignment_file data, either 'sam' or 'bam' [default %default]",
                dest = "format"),
    make_option(c("-c", "--column"), type = "character", default = "SAMPLE_ID",
                help = "Column name from the sample sheet to use as read folder names [default %default]",
                dest = "samplesColumn"),
    make_option(c("-i", "--inputFolder"), type = "character", default = "02-MappedReadsHISAT2",
                help = "Directory where the sequence data is stored [default %default]",
                dest = "inputFolder"),
    make_option(c('-E', '--countFolder'), type = 'character', default = '04-GeneCountsFeatCounts',
                help = 'Folder that the output will be stored [default %default]',
                dest = 'countsFolder'),
    make_option(c("-a", "--gtfTargets"), type = "character", default = "gtf_targets.gtf",
                help = "Path to the gtf file [target gtf] to run mapping against. If would like to run without gtf file, -g option is not required [default %default]",
                dest = "gtfTarget"),
    make_option(c("-T", "--processors"), type = "integer", default = 8,
                help = "Number of processors to use [defaults %default]",
                dest = "procs"),
    make_option(c("-Q", "--minaqual"), type = "integer", default = 20,
                help = "The minimum mapping quality score a read must satisfy in order to be counted. [defaults %default]",
                dest = "minaQual"),
    make_option(c("-q", "--sampleprocs"), type = "integer", default = 2,
                help = "Number of samples to process at time [default %default]",
                dest = "mprocs"),
    make_option(c('-s', '--stranded'), type = 'character', default = 'no',
                help = 'Select the output according to the strandedness of your data. options: no, yes and reverse [default %default]',
                dest = 'stranded'),
    make_option(c('-r', '--order'), type = 'character', default = 'name',
                help = 'Pos or name. Sorting order of alignment_file. Paired-end sequencing data must be sorted either by position or by read name, and the sorting order must be specified. Ignored for single-end data. [default %default]',
                dest = 'order'),
    make_option(c("-m", "--multiqc"), action = "store_true", default = FALSE,
                help  =  "Use this option if you want to run multiqc software. [default %default]",
                dest  =  "multiqc"),
    make_option(c("-p", "--consensus"), action = 'store_true', type = "character", default = FALSE,
                help = "Specify the minimum number of consensus subreads both
reads from the same pair must have. This argument is only applicable for paired-end read data. [default %default]",
                dest = "consensus"),
    make_option(c("-B", "--indexSplit"), action = 'store_true', type = "character", default = FALSE,
                help  =  "Create one block of index. The built index will not be split into multiple pieces. The more blocks an index has, the slower the mapping speed. [default %default]",
                dest  =  "indexSplit"),
    make_option(c("-C", "--countChimericFragments"), action = 'store_true', type = "character", default = FALSE,
                help  =  "If specified, the chimeric fragments (those fragments that have their two ends aligned to different chromosomes) will NOT be counted. [default %default]",
                dest  =  "countChimericFragments"),
    make_option(c("-z", "--single"), action = "store_true", default = FALSE,
                help = "Use this option if you have single-end files[doesn't need an argument]. [%default]",
                dest = "singleEnd"),
    make_option(c("-x", "--external"), action  =  'store', type  =  "character", default = 'FALSE',
                help = "A space delimeted file with a single line contain several external parameters from HISAT2 [default %default]",
                dest = "externalParameters"),
    make_option(c("-S", "--fromSTAR"), type = "character", default = FALSE,
                help = "This option will performes counting from STAR mapped files. Specify the Folder that contains BAM files from STAR [%default]",
                dest = "samplesFromSTAR")
)



# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list = option_list, description =  paste('Authors: OLIVEIRA, H.C. & CANTAO, M.E.', 'Version: 0.3.3', 'E-mail: hanielcedraz@gmail.com', sep = "\n", collapse = '\n')))



multiqc <- system('which multiqc > /dev/null', ignore.stdout = TRUE, ignore.stderr = TRUE)
if (opt$multiqc) {
    if (multiqc != 0) {
        write(paste("Multiqc is not installed. If you would like to use multiqc analysis, please install it or remove -m parameter"), stderr())
        stop()
    }
}



if (!(casefold(opt$stranded, upper = FALSE) %in% c("reverse", "yes", "no"))) {
    cat('\n')
    write(paste('May have a mistake with the argument in -s parameter. Please verify if the argument is written in the right way'), stderr())
    stop()
}




#cat('\n')
######################################################################
## loadSampleFile
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
    targets <- read.table(file,sep = "",header = TRUE,as.is = TRUE)
    if (!opt$singleEnd) {
        if (!all(c("SAMPLE_ID", "Read_1", "Read_2") %in% colnames(targets))) {
            cat('\n')
            write(paste("Expecting the three columns SAMPLE_ID, Read_1 and Read_2 in samples file (tab-delimited)\n"), stderr())
            stop()
        }
    }
    for (i in seq.int(nrow(targets$SAMPLE_ID))) {
        if (targets[i,column]) {
            ext <- unique(file_ext(dir(file.path(reads_folder, targets[i,column]), pattern = "gz")))
            if (length(ext) == 0) {
                write(paste("Cannot locate fastq or sff file in folder",targets[i,column], "\n"), stderr())
                stop()
            }
            # targets$type[i] <- paste(ext,sep="/")
        }
        else {
            ext <- file_ext(grep("gz", dir(file.path(reads_folder,targets[i, column])), value = TRUE))
            if (length(ext) == 0) {
                write(paste(targets[i,column], "is not a gz file\n"), stderr())
                stop()
            }

        }
    }
    write(paste("samples sheet contains", nrow(targets), "samples to process", sep = " "),stdout())
    return(targets)
}



#pigz <- system('which pigz 2> /dev/null')
if (system('which pigz 2> /dev/null', ignore.stdout = TRUE, ignore.stderr = TRUE) == 0) {
    uncompress <- paste('unpigz', '-p', opt$procs)
}else {
    uncompress <- 'gunzip'
}

######################################################################
## prepareCore
##    Set up the numer of processors to use
##
## Parameters
##    opt_procs: processors given on the option line
##    samples: number of samples
##    targets: number of targets
prepareCore <- function(opt_procs) {
    # if opt_procs set to 0 then expand to samples by targets
    if (detectCores() < opt$procs) {
        write(paste("number of cores specified (", opt$procs,") is greater than the number of cores available (",detectCores(),")",sep = " "),stdout())
        paste('Using ', detectCores(), 'threads')
    }
}






######################
if (opt$samplesFromSTAR == FALSE) {
        countingList <- function(samples, reads_folder, column){
        counting_list <- list()
        if (casefold(opt$format, upper = FALSE) == 'bam') {
            for (i in 1:nrow(samples)) {
                files <- dir(path = file.path(reads_folder), recursive = TRUE, pattern = paste0('.bam$'), full.names = TRUE)

                count <- lapply(c("_sam_sorted_pos.bam"), grep, x = files, value = TRUE)
                names(count) <- c("bam_sorted_pos")
                count$sampleName <-  samples[i,column]
                count$bam_sorted_pos <- count$bam_sorted_pos[i]

                counting_list[[paste(count$sampleName)]] <- count
                counting_list[[paste(count$sampleName, sep = "_")]]

            }
        }else if (casefold(opt$format, upper = FALSE) == 'sam') {
            for (i in 1:nrow(samples)) {
                files <- dir(path = file.path(reads_folder), recursive = TRUE, pattern = paste0('.sam$'), full.names = TRUE)

                count <- lapply(c("_unsorted_sample.sam"), grep, x = files, value = TRUE)
                names(count) <- c("unsorted_sample")
                count$sampleName <-  samples[i,column]
                count$unsorted_sample <- count$unsorted_sample[i]

                counting_list[[paste(count$sampleName)]] <- count
                counting_list[[paste(count$sampleName, sep = "_")]]

            }
        }
        write(paste("Setting up", length(counting_list), "jobs"),stdout())
        return(counting_list)
    }
} else if (opt$samplesFromSTAR != FALSE) {
        reads_folder <- opt$inputFolder
        countingList <- function(samples, reads_folder, column){
            counting_list <- list()
            for (i in 1:nrow(samples)) {
                files <- dir(path = file.path(reads_folder), recursive = TRUE, pattern = paste0('.bam$'), full.names = TRUE)

                count <- lapply(c("_Aligned.sortedByCoord.out.bam"), grep, x = files, value = TRUE)
                names(count) <- c("Aligned.sortedByCoord.out")
                count$sampleName <-  samples[i,column]
                count$Aligned.sortedByCoord.out <- count$Aligned.sortedByCoord.out[i]

                counting_list[[paste(count$sampleName)]] <- count
                counting_list[[paste(count$sampleName, sep = "_")]]
            }
            write(paste("Setting up", length(counting_list), "jobs"),stdout())
            return(counting_list)
    }
}






external_parameters <- opt$externalParameters
if (file.exists(external_parameters)) {
    con = file(external_parameters, open = "r")
    line = readLines(con, warn = FALSE, ok = TRUE)
}

samples <- loadSamplesFile(opt$samplesFile, opt$inputFolder, opt$samplesColumn)
procs <- prepareCore(opt$procs)

if (opt$samplesFromSTAR == FALSE) {
    couting <- countingList(samples, opt$inputFolder, opt$samplesColumn)
}
if (opt$samplesFromSTAR != FALSE) {
    couting <- countingList(samples, opt$samplesFromSTAR, opt$samplesColumn)
}
cat('\n')

counting_Folder <- opt$countsFolder
if (!file.exists(file.path(counting_Folder))) dir.create(file.path(counting_Folder), recursive = TRUE, showWarnings = FALSE)



####################
### Counting reads
####################

#featureCounts -Q 20 -p -B -C -s 2 -T 48 -a Sus_scrofa.Sscrofa11.1.95.gtf -o featureCounts/HE20.counts HE20.bam

if (casefold(opt$stranded, upper = FALSE) == 'no') {
    opt$stranded <- 0
}else if (casefold(opt$stranded, upper = FALSE) == 'yes') {
    opt$stranded  <- 1
}else if (casefold(opt$stranded, upper = FALSE) == 'reverse') {
    opt$stranded  <- 2
}


count.run <- mclapply(couting, function(index){
    try({
        system(paste('featureCounts',
                     '-Q',
                     opt$minaQual,
                     if (opt$consensus) paste('-p', '-B', '-C'),
                     '-s',
                     opt$stranded,
                     '-T',
                     opt$procs,
                     '-a',
                     opt$gtfTarget,
                     if (file.exists(external_parameters)) line,
                     if (opt$samplesFromSTAR == FALSE) {
                          if (casefold(opt$format, upper = FALSE) == 'sam')
                              {index$unsorted_sample}
                          else if (casefold(opt$format, upper = FALSE) == 'bam')
                              {index$bam_sorted_pos}
                     },
                     if (opt$samplesFromSTAR != FALSE) {
                         if (file.exists(opt$samplesFromSTAR)) {
                         paste0(index$Aligned.sortedByCoord.out)
                         } else {
                                 write(paste('folder doesn`t exist. please verify if it is correct'), stderr())
                             stop()
                         }
                     },
                     '-o', paste0(counting_Folder,'/', index$sampleName, 'featCount.output')
                     #paste0('2>', counting_Folder, '/', index$sampleName, '_HTSeq.out')
        ))
        system(paste('cat',
                     paste0(counting_Folder,'/', index$sampleName, 'featCount.output'),
                     '|',
                     "awk '{print $1, $7}'",
                     '|',
                     "sed '1d'",
                     '>',
                     paste0(counting_Folder,'/', index$sampleName, 'featCount.counts')
                     #'|',
                     #'mv',
                     #paste0(counting_Folder,'/', index$sampleName, '_featCountReady.counts'),
                     #paste0(counting_Folder,'/', index$sampleName, '_featCount.counts')

        ))})
}, mc.cores = opt$mprocs
)


if (!all(sapply(count.run, "==", 0L))) {
    write(paste("Something went wrong with FeatureCounts. Some jobs failed"),stderr())
    stop()
}else{
    write(paste('All jobs finished successfully'), stderr())
}



reportsall <- '05-Reports'
if (!file.exists(file.path(reportsall))) dir.create(file.path(reportsall), recursive = TRUE, showWarnings = FALSE)


TidyTable <- function(x) {
    final <- data.frame('Assigned' = x[1,2],
                        'Unassigned_Unmapped' = x[2,2],
                        'Unassigned_MappingQuality' = x[3,2],
                        'Unassigned_Duplicate' = x[6,2],
                        'Unassigned_NoFeatures' = x[10,2],
                        'Unassigned_Ambiguity' = x[12,2])
    return(final)
}

report_sample <- list()
for (i in samples[,1]) {
    report_sample[[i]] <- read.table(paste0(opt$countsFolder, '/', i,"featCount.output.summary"), header = F, as.is = T, fill = TRUE, skip = 1, blank.lines.skip = TRUE, text = TRUE)
}

df <- lapply(report_sample, FUN = function(x) TidyTable(x))
final_df <- do.call("rbind", df)

write.table(final_df, file = paste0(reportsall, '/', 'FeatCountsReportSummary.txt'), sep = "\t", row.names = TRUE, col.names = TRUE, quote = F)

# #
#MultiQC analysis
report_02 <- '02-Reports'
fastqcbefore <- 'FastQCBefore'
fastqcafter <- 'FastQCAfter'
multiqc_data <- 'multiqc_data'
baqcomqcreport <- 'reportBaqcomQC'

if (opt$multiqc) {
    if (file.exists(paste0(reportsall,'/',fastqcafter)) & file.exists(paste0(reportsall,'/',fastqcbefore)) & file.exists(paste0(reportsall,'/', multiqc_data))) {
        system2('multiqc', paste(opt$countsFolder, opt$inputFolder, paste0(reportsall,'/',fastqcbefore), paste0(reportsall,'/',fastqcafter), paste0(reportsall,'/',baqcomqcreport), '-o',  reportsall, '-f'))
    }else{
        system2('multiqc', paste(opt$countsFolder, '-o', reportsall, '-f'))
    }
}
cat('\n')

#
# #
# #
#
system2('cat', paste0(reportsall, '/', 'FeatCountsReportSummary.txt'))
# #
# #
#
#
cat('\n')
write(paste('How to cite:', sep = '\n', collapse = '\n', "Please, visit https://github.com/hanielcedraz/BAQCOM/blob/master/how_to_cite.txt", "or see the file 'how_to_cite.txt'"), stderr())
