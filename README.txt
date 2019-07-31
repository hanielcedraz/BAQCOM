
############################################################################################################
### BAQCOM - BAQCOM - Bioinformatics Analysis for Quality Control and Mapping                          #####
### Quality Control (Trimmomatic), Mapping (STAR | HISAT2) and Counting Reads (HTSeq | featuresCount)  #####
############################################################################################################
 

The BAQCOM is a friendly-user pipeline which implements two automated pipelines for RNA-Seq analysis using Trimmomatic for QC and  STAR for mapping the transcriptomes.


################
### INSTALATION
################


#STEP.1 - Install R and required libraries
	# Acsess https://cran.r-project.org
	# Install 'optparse' and 'parallel' packages


##################
### CONFIGURATION
##################


#STEP.2 - Download this repository to a preference path:
	 $ git clone https://github.com/hanielcedraz/BAQCOM.git

#STEP.3 - Run install.sh. This file will replace the trimmomatic path into the baqcomTrimmomatic and update ~/.bashrc or ~/.bash_profile directory path, so you can call the files from any directory.
	
	$ chmod +x ./install.sh
	$ ./install.sh
	
	If you would like to use multiqc analysis, please install it.
Installation:
        #If pip is not installed, please install as follow:
            curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
            python get-pip.py

        #You can install MultiQC from PyPI using pip as follow:
            pip install multiqc
	More information, please acsess https://github.com/ewels/MultiQC
	
	
	If you would like to use all power of the parallel, install pigz.
	

#############
### RUNNING
#############

#STEP.4 - Create a directory named 00-Fastq and move the .fastq.gz files into this directory:
	$ mkdir 00-Fastq

#STEP.5 - Create samples.txt:

	$ ./createSamples.sh

#This script will work perfectly if the file names in the 00-Fastq directory follow the structure:
#	File R1: SAMPLENAME_any_necessary_information_R1_001.fastq.gz
#	File R2: SAMPLENAME_any_necessary_information_R2_001.fastq.gz

	or to single-end files
#	File R1: SAMPLENAME_any_necessary_information_R1_001.fastq.gz


# If the files are splited in more than one R1 or R2 will be necessary to combine the equal R1 and R2 files. 
	#you may follow this command: 
		gunzip -c raw_fastq/*R1_001.fastq.gz > 00-Fastq/SAMPLEID_any_information_R1_001.fastq; gzip 00-Fastq/SAMPLEID_any_information_R1_001.fastq 00-Fastq/SAMPLEID_any_information_R1_001.fastq.gz; 
		gunzip -c raw_fastq/*R2_001.fastq.gz > 00-Fastq/SAMPLEID_any_information_R2_001.fastq; gzip 00-Fastq/SAMPLEID_any_information_R2_001.fastq 00-Fastq/SAMPLEID_any_information_R2_001.fastq.gz
	

#STEP.6 - Run the quality control with Trimmomatic (baqcomTrimmomatic pipeline):

# -p is the number of processors
# -a is the name of adapter. Default=TruSeq3-PE-2.fa

	#Other options for adapters (-a):
		#NexteraPE-PE.fa
		#TruSeq2-PE.fa
		#TruSeq2-SE.fa
		#TruSeq3-PE.fa
		#TruSeq3-SE.fa

	$ baqcomTrimmomatic.R -p 36 -s 2

STEP.7.1 - Mapping with STAR (baqcomSTARmapping pipeline):

#Download the last release of the genome(.fa) and annotation(.gtf) of specie that you will work with
#https://www.ensembl.org/info/data/ftp/index.html
#Generate the genome indexes files. This step needs to be performed just once for each genome/annotation version.  After the index generation step, the mapping and reads count will be started automatically.

#To index:
	$ baqcomSTARmapping.R -t /path/to/genome.fa -g /path/to/annotation_version/annotation_version.gtf -p 20 -q 2 

#To mapping:
	$ baqcom_mapping.R -t /path/to/index_STAR_folder -p 20 -q 3 


#obs. If needs to run the script with more than 20 thread, it must change ulimit in the system used (see "increasing_Limit_CentOS_7" file ==> https://naveensnayak.com/2015/09/17/increasing-file-descriptors-and-open-files-limit-centos-7/).


If you prefer, you can use HISAT2 to perform the mapping step and use HtseqCount or FeaturesCount to count reads
STEP.7.2 - Mapping with HISAT2 (baqcomHisat2Mapping pipeline):
	$ baqcomHisat2Mapping.R -t /path/to/genome.fa -g /path/to/annotation_version/annotation_version.gtf -p 20 -q 2
	
	
	STEP.7.2.1 - Counting reads with HTseqCounts or FeaturesCount (baqcomHtseqCounting or baqcomFeaturesCount pipeline)
		$ baqcomHtseqCounting.R -g /path/to/annotation_version/annotation_version.gtf
		
		$ baqcomFeaturesCount.R -a /path/to/annotation_version/annotation_version.gtf
		
