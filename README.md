
## BAQCOM - Bioinformatics Analysis for Quality Control and Mapping <br>
### Quality Control (Trimmomatic) and Mapping (STAR)
<br>
<br>

The BAQCOM is a friendly-user pipeline which implements two automated pipelines for RNA-Seq analysis using Trimmomatic for QC and  STAR for mapping the transcriptomes.
<br>
<br>
<br>
## STEP.1 - Download this repository to a preference path:<br>
	# Git is required<br>
	 $ git clone https://github.com/hanielcedraz/BAQCOM.git<br>
	 $ cd BAQCOM<br>
	 $ chmod +x install.sh<br>
	 $ ./install.sh<br>
<br>
<br>

## STEP.2 - Install R<br>
	# Access https://cran.r-project.org<br>
<br>
<br>

## STEP.3 - Install pip and MultiQC:
	# If you would like to use multiqc analysis, please install it.
	# Installation:
	# If pip is not installed, please install as follow:<br>
		$ wget https://bootstrap.pypa.io/get-pip.py -o get-pip.py<br>
		$ python get-pip.py<br>
	    
        # You can install MultiQC from PyPI using pip as follow:<br>
		$ pip install multiqc<br>
	# More information, please access https://github.com/ewels/MultiQC<br>
	<br>
	<br>

## STEP.4 - Install PigZ:
	# If you would like to use parallel, Install the pigz to speed up your analysis results.
	     # Centos
		$ sudo yum install pigz
	     # Ubuntu
	     	$ suto apt install pigz
<br>
<br>
<br>

## <a href="https://github.com/hanielcedraz/BAQCOM/blob/47ef1813f68f6c79f51e59a126024ab5d6ce1b3f/RELEASE_notes.md">RELEASEnotes</a>
