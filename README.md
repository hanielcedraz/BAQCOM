
## BAQCOM - Bioinformatics Analysis for Quality Control and Mapping <br>
### Quality Control (Trimmomatic), Mapping (STAR | HISAT2) and Counting Reads (HTSeq | featuresCount)
<br>
<br>

The BAQCOM is an user-friendly pipeline which implements five automated pipelines for RNA-Seq analysis using Trimmomatic for QC, STAR and HISAT2 for mapping and, HTSeq and featuresCount for counting reads.
<br>
<br>
<br>
## STEP.1 - Download this repository to a preference path:<br>
	Git is required
	 $ git clone https://github.com/hanielcedraz/BAQCOM.git
	 $ cd BAQCOM
	 $ chmod +x install.sh
	 $ ./install.sh
<br>
<br>

## STEP.2 - Install R<br>
	Access https://cran.r-project.org
<br>
<br>

## STEP.3 - Install pip, MultiQC and HTSeq-count:
	If you would like to use multiqc analysis, please install it.
	Installation:
	If pip is not installed, please install as follow:
		$ wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
		$ python get-pip.py
	    
        You can install MultiQC from PyPI using pip as follow:
		$ pip install multiqc
	More information, please access https://github.com/ewels/MultiQC
	
	
	
	Install HTSeq-count following the source documentation
	https://htseq.readthedocs.io/en/release_0.11.1/install.html#installation-on-linux
	
<br>
<br>

## STEP.4 - Install PigZ:
	To speed up your analysis results, install the pigz.
	     Centos
		$ sudo yum install pigz
	     Ubuntu
	     	$ sudo apt install pigz
<br>
<br>
<br>


## Examples:
	Run Quality Control
		$ baqcomTrimmomatic.R -p 36 -s 2 (paired-end)
		$ baqcomTrimmomatic.R -p 36 -s 2 -z (single-end)
		# -p option is the number of processors to use; 
		# -s option is the number of samples to use at time
		# -z option will run single end analysis
		# More options can be accessed with -h option (baqcomTrimmomatic.R)
		
	Run Index and Mapping
	Running STAR pipeline
		$ baqcomSTAR.R -t /path/to/reference_genome.fa -g /path/to/reference_annotation.gtf -p 20 -q 3 (paired-end)
		$ baqcomSTAR.R -t /path/to/reference_genome.fa -g /path/to/reference_annotation.gtf -p 20 -q 3 -z (single-end)
		# -t option is the directory where the reference genome is stored (required); 
		# -g option is the directory where the reference annotation is stored (optional but recomended); 
		# -p option is the number of processors to use; 
		# -q option is the number of samples to use at time;
		# -z option will run single end analysis;
		# More options can be accessed with -h option (baqcomSTAR.R -h)
			
	Running HISAT2 pipeline
		$ baqcomHisat2.R -t /path/to/reference_genome.fa -g /path/to/reference_annotation.gtf -p 20 -q 2 (paired-end)
		$ baqcomHisat2.R -t /path/to/reference_genome.fa -g /path/to/reference_annotation.gtf -p 20 -q 2 -z (single-end)
		# -t option is the directory where the reference genome is stored (required); 
		# -g option is the directory where the reference annotation is stored (optional but recomended); 
		# -p option is the number of processors to use;
		# -q option is the number of samples to use at time;
		# -z option will run single end analysis;
		# More options can be accessed with -h option (baqcomHisat2.R -h)
	
	Run counting reads
	Running HTseq
		$ baqcomHtseq.R -g /path/to/reference_annotation.gtf -q 2 (paired-end)
		$ baqcomHtseq.R -g /path/to/reference_annotation.gtf -q 2 -z (single-end)
		# -g option is the directory where the reference annotation is stored (required);
		# -q option is the number of samples to use at time;
		# -z option will run single end analysis;
		# More options can be accessed with -h option (baqcomHtseq.R -h)
		
	Running FeatureCounts
		$ baqcomFeatureCounts.R -a /path/to/reference_annotation.gtf -p 20 -q 2 (paired-end)
		$ baqcomFeatureCounts.R -a /path/to/reference_annotation.gtf -p 20 -q 2 -z (single-end)
		# -a option is the directory where the reference annotation is stored (required);
		# -p option is the number of processors to use;
		# -q option is the number of samples to use at time;
		# -z option will run single end analysis;
		# More options can be accessed with -h option (baqcomFeatureCounts.R -h)


## Differential Expression Gene
You will find some script to analyze differential expression genes <a href="https://github.com/hanielcedraz/DiffExpressGenes.git">here</a>


## <a href="https://github.com/hanielcedraz/BAQCOM/blob/master/RELEASE_notes.md">RELEASEnotes</a>
