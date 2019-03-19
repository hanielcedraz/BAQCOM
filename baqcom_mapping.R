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
    make_option(c("-i", "--inputFolder"), type="character", default="01-trimmomatic",
                help="Directory where the sequence data is stored [default %default]",
                dest="inputFolder"),    
    make_option(c("-b", "--mappingFolder"), type="character", default='02-mappingSTAR',
                help="Directory where to store the mapping results [default %default]",
                dest="mappingFolder"),
    make_option(c('-E', '--edgeR'), type = 'character', default = '04-EdgeR',
                help = 'Folder that contains fasta file genome [default %default]',
                dest = 'edgerFolder'),
    make_option(c("-t", "--mappingTargets"), type="character", default="mapping_targets.txt",
                help="Path to a fasta file, or tab delimeted file with [target name]\t[target fasta]\t[target gtf, optional] to run mapping against [default %default]",
                dest="mappingTarget"),
    make_option(c("-g", "--gtfTargets"), type="character", default="gtf_targets.txt",
                help="Path to a gtf file, or tab delimeted file with [target name]\t[target fasta]\t[target gtf] to run mapping against [default %default]",
                dest="gtfTarget"),
    make_option(c("-p", "--processors"), type="integer", default=8,
                help="number of processors to use [defaults %default]",
                dest="procs"),
    make_option(c("-q", "--sampleprocs"), type="integer", default=2,
                help="number of samples to process at time [default %default]",
                dest="mprocs"),
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
opt <- parse_args(OptionParser(option_list = option_list, description =  paste('Authors: OLIVEIRA, H.C. & CANTAO, M.E.', 'Version: 0.2.0', 'E-mail: hanielcedraz@gmail.com', sep = "\n", collapse = '\n')))




######################################################################
## loadSampleFile
"loadSamplesFile" <- function(file, reads_folder, column){
    ## debug
    file = opt$samplesFile; reads_folder = opt$inputFolder; column = opt$samplesColumn
    ##
    if ( !file.exists(file) ) {
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






######################################################################
## prepareCore
##    Set up the numer of processors to use
## 
## Parameters
##    opt_procs: processors given on the option line
##    samples: number of samples
##    targets: number of targets
"prepareCore" <- function(opt_procs){
    # if opt_procs set to 0 then expand to samples by targets
    if (detectCores() < opt$procs){
        write(paste("number of cores specified (", opt$procs,") is greater than the number of cores available (",detectCores(),")",sep=" "),stdout())
        paste('Using ', detectCores(), 'threads')
    }
}




######################
"mappingList" <- function(samples, reads_folder, column){
    mapping_list <- list()
    for (i in seq.int(to=nrow(samples))){
        reads <- dir(path=file.path(reads_folder,samples[i,column]),pattern="gz$",full.names=TRUE)
        map <- lapply(c("_PE1","_PE2"),grep,x=reads,value=TRUE)
        names(map) <- c("PE1","PE2")
        for(j in samples$SAMPLE_ID){
            mapping_list[[paste(map$sampleFolder,j[1],sep="_")]] <- map
            mapping_list[[paste(map$sampleFolder,j[1],sep="_")]]$target_name <- j[1]
            mapping_list[[paste(map$sampleFolder,j[1],sep="_")]]$target_path <- j[2]
        }
    }
    write(paste("Setting up",length(mapping_list),"jobs",sep=" "),stdout())
    return(mapping_list)
}


samples <- loadSamplesFile(opt$samplesFile, opt$inputFolder, opt$samplesColumn) 
procs <- prepareCore(opt$procs)
mapping <- mappingList(samples, opt$inputFolder, opt$samplesColumn)


####################
### GENOME GENERATE
####################

star.index.function <- function(){
    index_Folder <- paste(dirname(opt$gtfTarget), '/', 'index_STAR', '/', sep = '')
    if(!file.exists(file.path(paste(index_Folder, '/', 'Genome', sep = '')))){ dir.create(file.path(index_Folder), recursive = TRUE, showWarnings = FALSE)
        procs <- ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs));
        PE <-paste()
        argments_index <- c('--runMode', 'genomeGenerate', '--runThreadN', procs, '--genomeDir', index_Folder, '--genomeFastaFiles', opt$mappingTarget, '--sjdbGTFfile', opt$gtfTarget, '--sjdbOverhang', opt$annoJunction-1)
        system2('STAR', args = argments_index)
        
    } 
}
index_genom <- star.index.function()



## create output folder
mapping_Folder <- opt$mappingFolder
if(!file.exists(file.path(mapping_Folder))) dir.create(file.path(mapping_Folder), recursive = TRUE, showWarnings = FALSE)


# creating extracted_Folder
extracted_Folder <- opt$extractedFolder
if(!file.exists(file.path(extracted_Folder))) dir.create(file.path(extracted_Folder), recursive = TRUE, showWarnings = FALSE)


star.mapping <- mclapply(mapping, function(index){
    try({
        system(paste('STAR', 
                     '--genomeDir', 
                     paste0(dirname(opt$gtfTarget), '/', 'index_STAR', '/'), 
                     '--runThreadN', 
                     ifelse(detectCores() < opt$procs, detectCores(), paste(opt$procs)),
                     '--readFilesCommand',
                     paste(opt$Uncompress, '-c'),
                     '--readFilesIn', 
                     paste0(opt$inputFolder, '/', index$target_name, '_trim_PE1.fastq', collapse=","), 
                     paste0(opt$inputFolder, '/', index$target_name, '_trim_PE2.fastq', collapse=","), 
                     '--outSAMtype BAM Unsorted SortedByCoordinate', 
                     '--quantMode TranscriptomeSAM GeneCounts', 
                     '--outReadsUnmapped Fastx', 
                     '--outFileNamePrefix', 
                     paste0(opt$mappingFolder, '/', index$target_name, '_STAR_')))
    })
    
}, mc.cores = opt$mprocs
)

if (!all(sapply(star.mapping, "==", 0L))){
    write(paste("Something went wrong with STAR mapping some jobs failed"),stderr())
    stop()
}


# Moving all unmapped files from 02-mappingSTAR folder to 03-Ummapped folder
system(paste0('mv', opt$mappingFolder, '/*Unmapped.out.mate* ', opt$extractedFolder, '/'))

#Creating mapping report
Final_Folder <- opt$mappingFolder
samples <- read.table(opt$samplesFile, header = T, as.is = T)
report_sample <- array(dim = 0)
for (i in samples[,1]) {
    report_sample[i] <- read.table(paste0(Final_Folder, '/', i, '_STAR_Log.final.out'), header = F, as.is = T, fill = TRUE, sep = c('\t', '|', ' '), row.names = 1);
    report_sample <- as.data.frame(report_sample)
}

t(report_sample[c(5, 8, 9),])
trans_report <- t(report_sample[c(5, 8, 9, 23, 24, 25, 26, 29, 30),]); report_final <- data.frame(Samples = rownames(trans_report), trans_report[,1:9]); colnames(report_final) <- c('Samples', 'Input_reads', 'Mapped_reads', 'Mapped_reads_%', 'Mapped_multiLoci', 'Mapped_multiLoci_%', 'Mapped_manyLoci', 'Mapped_manyLoci_%', '%_reads_unmapped:short', '%_reads_unmapped:other')

write.table(report_final, file = 'mapping_report_STAR.txt', sep = "\t", row.names = FALSE, col.names = TRUE, quote = F)


# Creating EdgeR folder and preparing files
edgeR_Folder <- opt$edgerFolder
if(!file.exists(file.path(edgeR_Folder))) dir.create(file.path(edgeR_Folder), recursive = TRUE, showWarnings = FALSE)


comand_line <- paste('for i in $(ls ', opt$mappingFolder, '/); ', 'do a=`basename $i`;  b=`echo $a | cut -d "_" -f1`; cat ', '02-mappingSTAR', '/', '$b"_STAR_ReadsPerGene.out.tab" ', '| ', 'awk ','\'','{', 'print $1"\t" $2', '}','\'', ' >', ' ', edgeR_Folder, '/', '"$b"_ReadsPerGene.counts; done', sep = '')

system(comand_line, intern = FALSE)
