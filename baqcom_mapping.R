#!/usr/bin/env Rscript

#STAR
suppressPackageStartupMessages(library("tools"))
suppressPackageStartupMessages(library("parallel"))
suppressPackageStartupMessages(library("optparse"))

# specify our desired options in a list
# by default OptionParser will add an help option equivalent to
# make_option(c("-h", "--help"), action="store_true", default=FALSE,
# help="Show this help message and exit")
option_list <- list(
    make_option(c("-f", "--file"), type="character", default="samples.txt",
                help="The filename of the sample file [default %default]",
                dest="samplesFile"),
    make_option(c("-i", "--inputFolder"), type="character", default="01-trimmomatic",
                help="Directory where the sequence data is stored [default %default]",
                dest="inputFolder"),
    make_option(c("-b", "--mappingFolder"), type="character", default='02-mappingSTAR',
                help="Directory where to store the mapping results [default %default]",
                dest="mappingFolder"),
    make_option(c("-t", "--mappingTargets"), type="character", default="mapping_targets.txt",
                help="Path to a fasta file, or tab delimeted file with [target name]\t[target fasta]\t[target gtf, optional] to run mapping against [default %default]",
                dest="mappingTarget"),
    make_option(c("-g", "--gtfTargets"), type="character", default="gtf_targets.txt",
                help="Path to a gtf file, or tab delimeted file with [target name]\t[target fasta]\t[target gtf] to run mapping against [default %default]",
                dest="gtfTarget"),
    make_option(c("-p", "--processors"), type="integer", default=8,
                help="number of processors to use [default %default]",
                dest="procs"),
    make_option(c("-s", "--sjdboverhang"), type="integer", default=100,
                help="Specifie the length of the genomic sequence around the annotated junction to be used in constructing the splice junctions database [default %default]",
                dest="annoJunction"),
    make_option(c("-e", "--extractFolder"), type="character", default="03-Ummapped",
                help="if extractUnmapped, and/or extractMapped is TRUE, save resulting fastq to this folder [default %default]",
                dest="extractedFolder"),
    make_option(c("-z", "--readfilesCommand"), type = "character", default = "gunzip",
                help = "UncompressionCommandoption, whereUncompressionCommandis theun-compression command that takes the file name as input parameter, and sends the uncom-pressed output to stdout.",
                dest = "Uncompress")
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
opt <- parse_args(OptionParser(option_list = option_list, description =  paste('Authors: OLIVEIRA, H.C. & CANTAO, M.E.', 
'Version: 0.0.2', 'E-mail: hanielcedraz@gmail.com', sep = "\n", collapse = '\n')))


if ( !file.exists(opt$samplesFile) ) {
    write(paste("Sample file",file,"does not exist\n"), stderr())
    stop()
}


######################################################################
## prepareCore
##      Set up the numer of processors to use
if (detectCores() < opt$procs){
    write(paste("number of cores specified (", opt$procs,") is greater than the number of cores available (",detectCores(),")",sep=" "),stdout())
    paste('Using ', detectCores(), 'threads')
}

# creating extracted_Folder
extracted_Folder <- opt$extractedFolder
if(!file.exists(file.path(extracted_Folder))) dir.create(file.path(extracted_Folder), recursive = TRUE, showWarnings = FALSE)

####################
### GENOME GENERATE
####################

star.index.function <- function(){
    index_Folder <- paste(dirname(opt$gtfTarget), '/', 'index_STAR', '/', sep = '')
    if(!file.exists(file.path(paste(index_Folder, '/', 'Genome', sep = '')))){ dir.create(file.path(index_Folder), recursive = TRUE, showWarnings = FALSE)
        procs <- ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs));
        PE <-paste()
        argments_index <- c('--runMode', 'genomeGenerate', '--runThreadN', procs, '--genomeDir', index_Folder, '--genomeFastaFiles', opt$mappingTarget, '--sjdbGTFfile', opt$gtfTarget, '--sjdbOverhang', opt$annoJunction-1)
        system2('/Users/haniel/Documents/BAQCOM/STAR_mac_2.7.0e', args = argments_index)
        
    } 
}
index_genom <- star.index.function()

if (!file.exists(paste(dirname(opt$gtfTarget), '/', 'index_STAR', '/', 'Genome', sep = ''))) {
    write(paste("Genome file does not exist\n"), stderr())
    stop()
}

# Mapping analysis function
mapping.STAR.function <- function(){
    targets <- read.table(opt$samplesFile, header = T, as.is = T)
    for (i in 1:nrow(targets)){
        Final_Folder <- opt$mappingFolder
        if(!file.exists(file.path(Final_Folder))) dir.create(file.path(Final_Folder), recursive = TRUE, showWarnings = FALSE)
        input_read1 <- paste(opt$inputFolder, '/', targets[i,1], '_trim_PE1.fastq.gz', sep = "")
        input_read2 <- paste(opt$inputFolder, '/', targets[i,1], '_trim_PE2.fastq.gz', sep = "")
        output_sample <- paste(opt$mappingFolder, '/', targets[i,1], '_', 'STAR_', sep = "")
        procs <- ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs))
        samtype <- paste('--outSAMtype', 'BAM Unsorted', 'SortedByCoordinate', sep = ' ')
        quantMode <- paste('--quantMode', 'TranscriptomeSAM', 'GeneCounts', sep = ' ')
        gzip <- paste('--readFilesCommand', opt$Uncompress, '-c', sep = ' ' )
        argments_mapping <- c('--genomeDir', paste(dirname(opt$gtfTarget), '/', 'index_STAR', '/', sep = ''), '--runThreadN', procs, gzip, '--readFilesIn', input_read1, input_read2, samtype, quantMode, '--outReadsUnmapped', 'Fastx', '--outFileNamePrefix', output_sample)
        
        system2('STAR', args = argments_mapping)
        
    }
    
}
mapping_genom <- mapping.STAR.function()

# Moving all unmapped files from 02-mappingSTAR folder to 03-Ummapped folder
system('mv 02-mappingSTAR/*Unmapped.out.mate* 03-Ummapped/')

#Creating mapping report
Final_Folder <- opt$mappingFolder
samples <- read.table(opt$samplesFile, header = T, as.is = T)
report_sample <- array(dim = 0)
for (i in samples[,1]) {
    report_sample[i] <- read.table(paste(Final_Folder, '/', i, '_', 'STAR_Log.final.out', sep = ""), header = F, as.is = T, fill = TRUE, sep = c('\t', '|', ' '), row.names = 1);
    report_sample <- as.data.frame(report_sample)
}

t(report_sample[c(5, 8, 9),])
trans_report <- t(report_sample[c(5, 8, 9, 23, 24, 25, 26, 29, 30),]); report_final <- data.frame(Samples = rownames(trans_report), trans_report[,1:9]); colnames(report_final) <- c('Samples', 'Input_reads', 'Mapped_reads', 'Mapped_reads_%', 'Mapped_multiLoci', 'Mapped_multiLoci_%', 'Mapped_manyLoci', 'Mapped_manyLoci_%', '%_reads_unmapped:short', '%_reads_unmapped:other')

write.table(report_final, file = 'mapping_report_STAR.txt', sep = "\t", row.names = FALSE, col.names = TRUE, quote = F)


# Creating EdgeR folder and preparing files
edgeR_Folder <- '04-EdgeR'
if(!file.exists(file.path(edgeR_Folder))) dir.create(file.path(edgeR_Folder), recursive = TRUE, showWarnings = FALSE)


comand_line <- paste('for i in $(ls 02-mappingSTAR/); ', 'do a=`basename $i`;  b=`echo $a | cut -d "_" -f1`; cat ', '02-mappingSTAR', '/', '$b"_STAR_ReadsPerGene.out.tab" ', '| ', 'awk ','\'','{', 'print $1"\t" $2', '}','\'', ' >', ' 04-EdgeR/"$b"_ReadsPerGene.counts; done', sep = '')

system(comand_line, intern = FALSE)
