
## BAQCOM - Bioinformatics Analysis for Quality Control and Mapping <br>
### Quality Control (Trimmomatic), Mapping (STAR | HISAT2) and Counting Reads (HTSeq | featuresCount)
<br>
<br>

The BAQCOM is a friendly-user pipeline which implements two automated pipelines for RNA-Seq analysis using Trimmomatic for QC and  STAR for mapping the transcriptomes.
<br>
<br>
<br>
## STEP.1 - Download this repository to a preference path:<br>
	# Git is required
	 $ git clone https://github.com/hanielcedraz/BAQCOM.git
	 $ cd BAQCOM
	 $ chmod +x install.sh
	 $ ./install.sh
<br>
<br>

## STEP.2 - Install R<br>
	# Access https://cran.r-project.org
<br>
<br>

## STEP.3 - Install pip and MultiQC:
	# If you would like to use multiqc analysis, please install it.
	# Installation:
	# If pip is not installed, please install as follow:
		$ wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
		$ python get-pip.py
	    
        # You can install MultiQC from PyPI using pip as follow:
		$ pip install multiqc
	# More information, please access https://github.com/ewels/MultiQC
	
<br>
<br>

## STEP.4 - Install PigZ:
	# To speed up your analysis results, install the pigz.
	     # Centos
		$ sudo yum install pigz
	     # Ubuntu
	     	$ sudo apt install pigz
<br>
<br>
<br>

## Examples:
	## Run Quality Control
		$ baqcomTrimmomatic.R -p 36 -s 2
		# -p option is the number of processors to use; -s option is the number of samples to use at time
		# More options can be accessed with -h option (baqcomTrimmomatic.R)
		
	## Run Index and Mapping
		# Running STAR pipeline
			$ baqcomSTARmapping.R -t /path/to/reference_genome.fa -g /path/to/reference_annotation.gtf -p 20 -q 3
			# -t option is the directory where the reference genome is stored; -g option (optional but recomended) is the directory where the reference annotation is stored; -p option is the number of processors to use; -q option is the number of samples to use at time
			# More options can be accessed with -h option (baqcomSTARmapping.R -h)
			
		# Running HISAT2 pipeline
			$ baqcomHisat2Mapping.R -t /path/to/reference_genome.fa -g /path/to/reference_annotation.gtf -p 20 -q 2
			# -t option is the directory where the reference genome is stored; -g option (optional but recomended) is the directory where the reference annotation is stored; -p option is the number of processors to use; -q option is the number of samples to use at time
			# More options can be accessed with -h option (baqcomHisat2Mapping.R -h)
	
	## Run counting reads
		# Running HTseq
			$baqcomHtseqCounting.R -g /path/to/reference_annotation.gtf -q 2
			# -g option is the directory where the reference annotation is stored; -q option is the number of samples to use at time
		
		# Running FeatureCounts
			$ baqcomFeaturesCount.R -a /path/to/reference_annotation.gtf -p 20 -q 2
			# -a option (optional but recomended) is the directory where the reference annotation is stored; -p option is the number of processors to use; -q option is the number of samples to use at time

## <a href="https://github.com/hanielcedraz/BAQCOM/blob/master/RELEASE_notes.md">RELEASEnotes</a>
