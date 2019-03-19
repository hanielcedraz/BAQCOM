
##############################################################################
### BAQCOM - BAQCOM - Bioinformatics Analysis for Quality Control and Mapping
### Quality Control (Trimmomatic) and Mapping (STAR)
##############################################################################
 
The BAQCOM is a friendly-user pipeline which implements two automated pipelines for RNA-Seq analysis using Trimmomatic for QC and  STAR for mapping the transcriptomes.


################
### INSTALATION
################


#STEP.1 - Install R and required libraries
	#Install 'optparse' and 'parallel' packages


#################
### CONFIGURATION
#################


#STEP.2 - Download this repository to a preference path:
	 $ git clone https://github.com/hanielcedraz/BAQCOM.git

#STEP.3 - Run install.sh. This file will replace the trimmomatic path into the .baqcom_qc and update ~/bash_profile directory path, so you can call the files from any directory.

	$ ./install.sh

#############
### RUNNING
#############

#STEP.4 - Create a directory named 00-Fastq and move the .fastq.gz files into this directory:
	$ mkdir 00-Fastq

#STEP.5 - Create samples.txt:

	$ ./create_samples.sh

#This script will work perfectly if the file names in the 00-Fastq directory follow the structure:

#	File R1: SAMPLENAME_any_necessary_information_R1_001.fastq.gz
#	File R2: SAMPLENAME_any_necessary_information_R2_001.fastq.gz

# If the files are splited in more than one R1 or R2 will be necessary to combine the equal R1 and R2 files. 
	#you may follow this command: gunzip -c raw_fastq/*R1_001.fastq.gz > SAMPLEID_any_information_R1_001.fastq; gzip 00-Fastq/SAMPLEID_any_information_R1_001.fastq 00-Fastq/SAMPLEID_any_information_R1_001.fastq.gz; gunzip -c raw_fastq/*R2_001.fastq.gz > SAMPLEID_any_information_R2_001.fastq; gzip 00-Fastq/SAMPLEID_any_information_R2_001.fastq 00-Fastq/SAMPLEID_any_information_R2_001.fastq.gz
	

#STEP.6 - Run the quality control with Trimmomatic (baqcom_qc pipeline):

# -p is the number of processors
# -a is the name of adapter. Default=TruSeq2-PE.fa

	#Other options for adapters (-a):
		#NexteraPE-PE.fa
		#TruSeq2-SE.fa
		#TruSeq3-PE-2.fa
		#TruSeq3-PE.fa
		#TruSeq3-SE.fa

	$ baqcom_qc.R -p 36 

STEP.7 - Mapping with STAR (baqcom_mapping pipeline):

#Download the last release of the genome(.fa) and annotation(.gtf) of specie that you will work with
#https://www.ensembl.org/info/data/ftp/index.html
#Generate the genome indexes files. This step needs to be performed just once for each genome/annotation version.  After the index generation step, the mapping will be started automatically.

#This code will generate index and mapping.

> baqcom_mapping.R -p 20 -q 3 -t /genome_annotation_directory/genome.fa -g /genome_annotation_directory/annotation_version/annotation_version.gtf 


#obs. If needs to run the script with more than 20 thread, it must change ulimit in the system used (see "increasing_Limit_CentOS_7" file ==> https://naveensnayak.com/2015/09/17/increasing-file-descriptors-and-open-files-limit-centos-7/).

