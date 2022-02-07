#!/usr/bin/env Rscript


suppressPackageStartupMessages(library("tools"))
suppressPackageStartupMessages(library("parallel"))
suppressPackageStartupMessages(library("optparse"))
suppressPackageStartupMessages(library("baqcomPackage"))

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
    make_option(c('-E', '--countFolder'), type = 'character', default = '04-GeneCountsHTSeq',
                help = 'Directory where the output is stored [default %default]',
                dest = 'countsFolder'),
    make_option(c("-g", "--gtfTargets"), type = "character", default = "gtf_targets.gtf",
                help = "Path to the gtf file [target gtf] to run mapping against. If would like to run without gtf file, -g option is not required [default %default]",
                dest = "gtfTarget"),
    make_option(c("-p", "--processors"), type = "integer", default = 8,
                help = "Number of processors to use [defaults %default]",
                dest = "procs"),
    make_option(c("-a", "--minaqual"), type = "integer", default = 20,
                help = "Skip all reads with alignment quality lower than the given minimum value [defaults %default]",
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
                help  =  "Use this option if you want to run multiqc analysis. [default %default]",
                dest  =  "multiqc"),
    make_option(c("-z", "--libraryType"),
                type  = 'character', default = "pairEnd",
                help = "The library type to use. Available: 'pairEnd' or 'singleEnd'. [ default %default]",
                dest = "libraryType"),
    make_option(c("-x", "--external"), action  =  'store', type  =  "character", default = 'FALSE',
                help = "A space delimeted file with a single line containing external parameters from HISAT2 [default %default]",
                dest = "externalParameters")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list = option_list, description =  paste('Authors: OLIVEIRA, H.C. & CANTAO, M.E.', 'Version: 0.3.5', 'E-mail: hanielcedraz@gmail.com', sep = "\n", collapse = '\n')))



multiqc <- system('which multiqc > /dev/null', ignore.stdout = TRUE, ignore.stderr = TRUE)
if (opt$multiqc) {
    if (multiqc != 0) {
        write(paste("Multiqc is not installed. If you would like to use multiqc analysis, please install it or remove -r parameter"), stderr())
        stop()
    }
}



if (!(casefold(opt$stranded, upper = FALSE) %in% c("reverse", "yes", "no"))) {
    cat('\n')
    write(paste('May have a mistake with the argument in -s parameter. Please verify if the argument is written in the right way'), stderr())
    stop()
}




#pigz <- system('which pigz 2> /dev/null')
if (system('which pigz 2> /dev/null', ignore.stdout = TRUE, ignore.stderr = TRUE) == 0) {
    uncompress <- paste('unpigz', '-p', opt$procs)
}else {
    uncompress <- 'gunzip'
}




external_parameters <- opt$externalParameters
if (file.exists(external_parameters)) {
    con = file(external_parameters, open = "r")
    line = readLines(con, warn = FALSE, ok = TRUE)
}

# samples <- loadSamplesFile(opt$samplesFile, opt$inputFolder, opt$samplesColumn)
# procs <- prepareCore(opt$procs)
# couting <- countingList(samples, opt$inputFolder, opt$samplesColumn)


samples <- loadSamplesFile(file = opt$samplesFile, reads_folder = opt$inputFolder, column = opt$samplesColumn, libraryType = opt$libraryType)
cat("samples\n")
print(samples)
procs <- prepareCore(nThreads = opt$procs)
cat("Number of procs to use\n")
print(procs)
couting <- createSampleList(samples = samples, reads_folder = opt$inputFolder, column = opt$samplesColumn, fileType = opt$format, libraryType = opt$libraryType, program = "htseq")
cat("couting\n")
print(couting)

cat('\n')

counting_Folder <- opt$countsFolder
if (!file.exists(file.path(counting_Folder))) dir.create(file.path(counting_Folder), recursive = TRUE, showWarnings = FALSE)



####################
### Counting reads
####################

count.run <- mclapply(couting, function(index){
    try({
        system(paste('htseq-count',
                     '-f',
                        casefold(opt$format, upper = FALSE),
                     '-n',
                        ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs)),
                     '-r',
                        casefold(opt$order, upper = FALSE),
                     '-s',
                         casefold(opt$stranded, upper = FALSE),
                     '-a',
                        opt$minaQual,
                     if (casefold(opt$format, upper = FALSE) == 'sam')
                         index$unsorted_sample,
                     if (casefold(opt$format, upper = FALSE) == 'bam')
                         index$bam_sorted_pos,
                     opt$gtfTarget,
                     if (file.exists(external_parameters)) line,
                     '1>', paste0(counting_Folder,'/', index$sampleName, '_HTSeq.counts'),
                     paste0('2>', counting_Folder, '/', index$sampleName, '_HTSeq.out')
                     ))})
}, mc.cores = opt$mprocs
)


if (!all(sapply(count.run, "==", 0L))) {
     write(paste("Something went wrong with HTSeq-Count. Some jobs failed"),stderr())
     stop()
}else{
     write(paste('All jobs finished successfully'), stderr())
}

reportsall <- '05-Reports'
if (!file.exists(file.path(reportsall))) dir.create(file.path(reportsall), recursive = TRUE, showWarnings = FALSE)


#####################################################
## write out summary tables
htseqTables <- sapply(samples$SAMPLE_ID, function(x){
    print(paste("Generating HTSeqReportSummary to", x[1]))
    filesToRead <- unlist(sapply(unique(samples[,opt$samplesColumn]), function(x) file.path(opt$countsFolder, paste0(x[1],'_HTSeq.counts'))))
    #	filesToRead <- unlist(sapply(file.path(opt$mappingFolder,unique(samples[,opt$samplesColumn])),dir,pattern=paste(tgt[1],"idxstats",sep="."),full.names=TRUE))
    info <- lapply(filesToRead, read.table, sep = "\t", as.is = TRUE)
    names <- info[[1]][,1]
    statidx <- grep("__", names)
    stat = sapply(info, function(x) x[statidx,2])
    info = sapply(info, function(x) x[-statidx,2])

    htseq_data <- data.frame("Reads_in_feature" = colSums(info), "Reads_NOT_in feature" = stat[1,], "Reads_ambiguous" = stat[2,], "Reads_too_low_qual" = stat[3,], "Percent_Assigned_To_Feature" = colSums(info)/(colSums(info) + colSums(stat)), "Number_of_Features" = nrow(info), "Number_of_0_count features" = apply(info, 2, function(x)sum(x == 0)))
    write.table(htseq_data, file.path(reportsall, paste0("HTSeqCountingReportSummary.txt")), row.names = TRUE, col.names = TRUE, quote = FALSE, sep = "\t")
    #    htseq_data
})


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
# if (file.exists(report_02)) {
#     system(paste('cp -r', paste0(report_02, '/*'), paste0(reportsall,'/')))
#     unlink(report_02, recursive = TRUE)
# }
# #
# #
#
system2('cat', paste0(reportsall, '/', 'HTSeqCountingReportSummary.txt'))

#
cat('\n')
write(paste('How to cite:', sep = '\n', collapse = '\n', "Please, visit https://github.com/hanielcedraz/BAQCOM/blob/master/how_to_cite.txt", "or see the file 'how_to_cite.txt'"), stderr())
