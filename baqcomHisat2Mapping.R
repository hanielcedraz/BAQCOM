#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("tools"))
suppressPackageStartupMessages(library("parallel"))
suppressPackageStartupMessages(library("optparse"))

option_list <- list(
    make_option(c("-f", "--file"), type = "character", default = "samples.txt",
                help = "The filename of the sample file [default %default]",
                dest = "samplesFile"),
    make_option(c("-c", "--column"), type = "character", default = "SAMPLE_ID",
                help = "Column name from the sample sheet to use as read folder names [default %default]",
                dest = "samplesColumn"),
    make_option(c("-r", "--inputFolder"), type = "character", default = "01-CleanedReads",
                help = "Directory where the sequence data is stored [default %default]",
                dest = "inputFolder"),
    make_option(c("-b", "--mappingFolder"), type = "character", default = '02-MappedReadsHISAT2',
                help = "Directory where to store the mapping results [default %default]",
                dest = "mappingFolder"),
    make_option(c("-e", "--extractFolder"), type = "character", default = "03-UnmappedReadsHISAT2",
                help = "Directory where to store the ummapping reads [default %default]",
                dest = "extractedFolder"),
    make_option(c("-u", "--unmapped"), action = "store_true", default = FALSE,
                help = "This option rus samtools to extract unmapped reads from bam or sam files. [%default]",
                dest = "unmapped"),
    make_option(c("-t", "--mappingTargets"), type = "character", default = "mapping_targets.fa",
                help = "Path to a fasta file, or tab delimeted file with [target fasta] to run mapping against (default %default); or path to the directory where the genome indices are stored (path to the genoma_file/index_HISAT2.)",
                dest = "mappingTarget"),
    make_option(c("-g", "--gtfTargets"), type = "character", default = "gtf_targets.gtf",
                help = "Path to a gtf file, or tab delimeted file with [target gtf] to run mapping against. If would like to run without gtf file, -g option is not required [default %default]",
                dest = "gtfTarget"),
    make_option(c("-p", "--processors"), type = "integer", default = 8,
                help = "Number of processors to use [defaults %default]",
                dest = "procs"),
    make_option(c("-q", "--sampleprocs"), type = "integer", default = 2,
                help = "Number of samples to process at time [default %default]",
                dest = "mprocs"),
    make_option(c("-m", "--multiqc"), action = "store_true", default = FALSE,
                help  =  "Use this option if you would like to run multiqc analysis. [default %default]",
                dest  =  "multiqc"),
    make_option(c("-x", "--external"), action  =  'store', type  =  "character", default = FALSE,
                help = "A space delimeted file with a single line contain several external parameters from HISAT2 [default %default]",
                dest = "externalParameters"),
    make_option(c("-i", "--index"), action = "store_true", default = FALSE,
                help = "This option directs HISAT2 to run genome indices generation job. [%default]",
                dest = "indexBuild"),
    make_option(c("-o", "--indexFiles"), type  =  'character', default = 'ht2_base',
                help = "The basename of the index files to write. [%default]",
                dest = "indexFiles"),
    make_option(c("-w", "--pmode"), action = "store_true", default = FALSE,
                help  =  "Use this option if you would like to run two pass mode mapping. [default %default]",
                dest  =  "PassMode"),
    make_option(c("-s", "--samtools"), action = "store_true", default = FALSE,
                help = "Use this option if you want to convert the SAM files to sorted BAM. samtools is required [%default]",
                dest = "samtools"),
    make_option(c("-d", "--delete"), action = "store_true", default = FALSE,
                help = "Use this option if you want to delete the SAM files after convert to sorted BAM. [%default]",
                dest = "deleteSAMfiles")

)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list = option_list, description =  paste('Authors: OLIVEIRA, H.C. & CANTAO, M.E.', 'Version: 0.3.0', 'E-mail: hanielcedraz@gmail.com', sep = "\n", collapse = '\n')))



multiqc <- system('which multiqc > /dev/null', ignore.stdout = TRUE, ignore.stderr = TRUE)
if (opt$multiqc) {
    if (multiqc != 0) {
        write(paste("Multiqc is not installed. If you would like to use multiqc analysis, please install it or remove -r parameter"), stderr())
        stop()
    }
}



# if (!(opt$stranded %in% c("reverse", "yes", "no"))){
#     cat('\n')
#     write(paste('May have a mistake with the argument in -s parameter. Please verify if the argument is written in the right way'), stderr())
#     stop()
# }


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
    if (!all(c("SAMPLE_ID", "Read_1", "Read_2") %in% colnames(targets))) {
        write(paste("Expecting the three columns SAMPLE_ID, Read_1 and Read_2 in samples file (tab-delimited)\n"), stderr())
        stop()
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
mappingList <- function(samples, reads_folder, column){
    mapping_list <- list()
    for (i in 1:nrow(samples)) {
        reads <- dir(path = file.path(reads_folder), pattern = "fastq.gz$", full.names = TRUE)
        # for (i in seq.int(to=nrow(samples))){
        #     reads <- dir(path=file.path(reads_folder,samples[i,column]),pattern="gz$",full.names=TRUE)
        map <- lapply(c("_PE1", "_PE2", "_SE1", "_SE2"), grep, x = reads, value = TRUE)
        names(map) <- c("PE1", "PE2", "SE1", "SE2")
        map$sampleName <-  samples[i,column]
        map$PE1 <- map$PE1[i]
        map$PE2 <- map$PE2[i]
        map$SE1 <- map$SE1[i]
        map$SE2 <- map$SE2[i]
        for(j in samples$SAMPLE_ID) {
            mapping_list[[paste(map$sampleName)]] <- map
            mapping_list[[paste(map$sampleName, sep = "_")]]
        }
    }
    write(paste("Setting up", length(mapping_list), "jobs"), stdout())
    return(mapping_list)
}


external_parameters <- opt$externalParameters
if (file.exists(external_parameters)) {
    con = file(external_parameters, open = "r")
    line = readLines(con, warn = FALSE, ok = TRUE)
}

samples <- loadSamplesFile(opt$samplesFile, opt$inputFolder, opt$samplesColumn)
procs <- prepareCore(opt$procs)
mapping <- mappingList(samples, opt$inputFolder, opt$samplesColumn)

cat('\n')


####################
### GENOME GENERATE
####################

if (file.exists(opt$gtfTarget)) {
    system(paste('hisat2_extract_exons.py',  opt$gtfTarget, '>', 'exons_hisat2.txt'))
    system(paste('hisat2_extract_splice_sites.py', opt$gtfTarget, '>', 'splicesites_hisat2.txt'))
}



index_Folder <- paste(dirname(opt$mappingTarget), '/', 'index_HISAT2', '/', sep = '')
if (!file.exists(file.path(index_Folder))) dir.create(file.path(index_Folder), recursive = TRUE, showWarnings = FALSE)





genome.index.function <- function(){
    try({
    system(paste('hisat2-build',
                 '-p', ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs)),
                 if (file.exists(opt$gtfTarget)) paste('--ss', 'splicesites_hisat2.txt',
                                                                                                   '--exon', 'exons_hisat2.txt'),

                 opt$mappingTarget, paste0(index_Folder,opt$indexFiles),
                 if (file.exists(external_parameters)) line)
    )
    })
}

if (length(dir(path = index_Folder, full.names = TRUE, all.files = FALSE, pattern = '.ht2$')) == 0) {
    index_genom <- genome.index.function()
}
userInput <- function(question) {
    cat(question)
    con <- file("stdin")
    on.exit(close(con))
    n <- readLines(con, n = 1)
    return(n)
}

if (opt$indexBuild) {
    if (length(dir(path = index_Folder, full.names = TRUE, all.files = FALSE, pattern = '.ht2$')) == 0) {
        index_genom <- genome.index.function()
}else{
    write(paste("Index genome files already exists."), stderr())
    repeat {
        inp <- userInput("Would you like to delete and re-run index generation? (yes or no) ")
        if (inp %in% c("yes", "no")) {break()
        }else {write("Specify 'yes' or 'no'", stderr())
                }
    }

    if (inp == "yes") {index_genom <- genome.index.function()
    }
    }
}





## create output folder
mapping_Folder <- opt$mappingFolder
if (!file.exists(file.path(mapping_Folder))) dir.create(file.path(mapping_Folder), recursive = TRUE, showWarnings = FALSE)


# creating extracted_Folder
# extracted_Folder <- opt$extractedFolder
# if(!file.exists(file.path(extracted_Folder))) dir.create(file.path(extracted_Folder), recursive = TRUE, showWarnings = FALSE)

#creating report folder
reportsall <- '05-Reports'
if (!file.exists(file.path(reportsall))) dir.create(file.path(reportsall), recursive = TRUE, showWarnings = FALSE)

cat('\n')
#Mapping
# sam_folder <- paste0(mapping_Folder,'/', 'sam_folder')
# if (!file.exists(file.path(sam_folder))) dir.create(file.path(sam_folder), recursive = TRUE, showWarnings = FALSE)

index_names <- substr(basename(paste0(dir(index_Folder, full.names = TRUE))), 1, nchar(basename(paste0(dir(index_Folder, full.names = TRUE)))) - 6)

novel_names <- substr(basename(paste0(samples[1,1])), 1, nchar(basename(paste0(samples[1,1]))) - 02)

hisat2.mapping <- mclapply(mapping, function(index){
    write(paste('Starting Mapping sample', index$sampleName), stderr())
    try({
        system(paste('hisat2',
                     '-p', ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs)),
                     '-x',
                        paste0(index_Folder,index_names),
                     '-1',
                        paste0(index$PE1, collapse = ","),
                     '-2',
                        paste0(index$PE2, collapse = ","),
                     paste0(mapping_Folder, '/', index$sampleName, '_unsorted_sample.sam'),
                     if (opt$PassMode) {
                     paste('--novel-splicesite-outfile', paste(novel_names,'splicesites','novel.txt', sep = '_'))
                     paste('--novel-splicesite-infile', paste(novel_names,'splicesites','novel.txt', sep = '_'))},
                     '2>', paste0(mapping_Folder,'/',index$sampleName,'_summary.log'),
                     if (file.exists(external_parameters)) line))})
}, mc.cores = opt$mprocs
)


if (!all(sapply(hisat2.mapping, "==", 0L))) {
    write(paste("Something went wrong with HISAT2 mapping. Some jobs failed"),stderr())
    stop()
}


samtoolsList <- function(samples, reads_folder, column){
    samtoolsfiles <- list()
    for (i in 1:nrow(samples)) {
        samfiles <- dir(path = file.path(mapping_Folder), recursive = TRUE, pattern = ".sam$", full.names = TRUE)
        maps <- lapply(c("_unsorted_sample"), grep, x = samfiles, value = TRUE)
        names(maps) <- c("unsorted_sample")
        maps$sampleName <-  samples[i,column]
        maps$unsorted_sample <- maps$unsorted_sample[i]

        samtoolsfiles[[paste(maps$sampleName)]] <- maps
        samtoolsfiles[[paste(maps$sampleName, sep = "_")]]

    }
    write(paste("Setting up", length(samtoolsfiles), "jobs"),stdout())
    return(samtoolsfiles)
}

if (opt$samtools) {
santools.map <- samtoolsList(samples, opt$inputFolder, opt$samplesColumn)

samtools.run <- mclapply(santools.map, function(index){
    write(paste('Starting convert sam to bam with samtools:', index$sampleName), stderr())
    try({
        system(paste('samtools',
                     'sort',
                     '--threads', ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs)),
                     paste0(index$unsorted_sample, collapse = ","),
                     '>', paste0(opt$mappingFolder,'/', index$sampleName, '_sam_sorted_pos.bam')))})
}, mc.cores = opt$mprocs
)


if (!all(sapply(samtools.run, "==", 0L))) {
    write(paste("Something went wrong with SAMTOOLS. Some jobs failed"),stderr())
    stop()
}

}

if (opt$deleteSAMfiles) {
    unlink(dir(path = file.path(mapping_Folder), recursive = TRUE, pattern = ".sam$", full.names = TRUE))
}



# creating extracted_Folder
if (opt$unmapped) {
    if (!opt$samtools) {
        santools.map <- samtoolsList(samples, opt$inputFolder, opt$samplesColumn)
        extracted_Folder <- opt$extractedFolder
        if (!file.exists(file.path(extracted_Folder))) dir.create(file.path(extracted_Folder), recursive = TRUE, showWarnings = FALSE)
        samtools.ummaped <- mclapply(santools.map, function(index){
            write(paste('Starting extract ummapped reads from sample', index$sampleName), stderr())
            try({
                system(paste('samtools',
                             'view',
                             '--threads', ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs)),
                             '-b',
                             '-f',
                             4,
                             paste0(index$unsorted_sample),
                             '>', paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_unsorted_pos.bam')))
                system(paste('samtools',
                             'bam2fq',
                             paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_unsorted_pos.bam'),
                             '>', paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_unsorted_pos.fastq')

                ))
                unlink(paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_unsorted_pos.bam'))})
        }, mc.cores = opt$mprocs
        )
    }else if (opt$samtools) {
        santools.map <- samtoolsList(samples, opt$inputFolder, opt$samplesColumn)
        extracted_Folder <- opt$extractedFolder
        if (!file.exists(file.path(extracted_Folder))) dir.create(file.path(extracted_Folder), recursive = TRUE, showWarnings = FALSE)
        #
        samtools.ummaped <- mclapply(santools.map, function(index){
            write(paste('Starting extract ummapped reads from sample', index$sampleName), stderr())
            try({
                system(paste('samtools',
                             'view',
                             '--threads', ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs)),
                             '-b',
                             '-f',
                                 4,
                             paste0(opt$mappingFolder,'/',index$sampleName,'_sam_sorted_pos.bam'),
                             '>', paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_sorted_pos.nam')))
                system(paste('samtools',
                             'bam2fq',
                             paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_sorted_pos.bam'),
                             '>', paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_sorted_pos.fastq')

                ))
                unlink(paste0(opt$extractedFolder,'/', index$sampleName, '_unmapped_unsorted_pos.bam'))})
        }, mc.cores = opt$mprocs
        )


    if (!all(sapply(samtools.run, "==", 0L))) {
        write(paste("Something went wrong with SAMTOOLS. Some jobs failed"),stderr())
        stop()
        }
    }
}



if (opt$deleteSAMfiles) {
    unlink(dir(path = file.path(mapping_Folder), recursive = TRUE, pattern = ".sam$", full.names = TRUE))
}


#Creating mapping report

# Final_Folder <- opt$mappingFolder
# samples <- read.table(opt$samplesFile, header = T, as.is = T)

TidyTable <- function(x) {
    final <- data.frame('Input_Read_Pairs' = x[1,3], # add you "samples" before that
                        'Mapped_reads' = x[3,5],
                        'Percent_Mapped_reads' = x[3,6],
                        'Reads_unmapped' = x[2,5],
                        'Percent_reads_unmapped' = x[2,6],
                        'Reads_multi_mapped' = x[4,5],
                        'Percent_reads_uniquely_mapped' = x[4,6])
    return(final)
}

report_sample <- list()
for (i in samples[,1]) { # change this to your "samples"
    report_sample[[i]] <- read.table(paste0(mapping_Folder, '/', i,"_summary.log"),
                                     header = F, as.is = T, fill = TRUE, sep = ' ',
                                     skip = 2, blank.lines.skip = TRUE, text = TRUE)
}

df <- lapply(report_sample, FUN = function(x) TidyTable(x))
final_df <- do.call("rbind", df)

    write.table(final_df, file = paste0(reportsall, '/', 'HISAT2MappingReportSummary.txt'), sep = "\t", row.names = TRUE, col.names = TRUE, quote = F)


#
#MultiQC analysis
report_02 <- '02-Reports'
fastqcbefore <- 'FastQCBefore'
fastqcafter <- 'FastQCAfter'
multiqc_data <- 'multiqc_data'
baqcomqcreport <- 'reportBaqcomQC'
if (opt$multiqc) {
    if (file.exists(paste0(report_02,'/',fastqcafter)) & file.exists(paste0(report_02,'/',fastqcbefore)) & file.exists(paste0(report_02,'/', multiqc_data))) {
        system2('multiqc', paste(opt$mappingFolder, paste0(report_02,'/',fastqcbefore), paste0(report_02,'/',fastqcafter), paste0(report_02,'/',baqcomqcreport), '-o',  reportsall, '-f'))
        unlink(paste0(report_02, '/', 'multiqc*'), recursive = TRUE)
        system(paste('cp -r', paste0(report_02, '/*'), paste0(reportsall,'/')))
    }else{
        system(paste('cp -r', paste0(report_02, '/*'), paste0(reportsall,'/')))
        system2('multiqc', paste(opt$mappingFolder, '-o', reportsall, '-f'))
    }
}
cat('\n')

#

if (file.exists(report_02)) {
    system(paste('cp -r', paste0(report_02, '/*'), paste0(reportsall,'/')))
    unlink(report_02, recursive = TRUE)
}
#

system2('cat', paste0(reportsall, '/', 'HISAT2MappingReportSummary.txt'))
cat('\n')
write(paste('How to cite:', sep = '\n', collapse = '\n', "Please, visit https://github.com/hanielcedraz/BAQCOM/blob/master/how_to_cite.txt", "or see the file 'how_to_cite.txt'"), stderr())
