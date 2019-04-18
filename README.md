
## BAQCOM - Bioinformatics Analysis for Quality Control and Mapping <br>
### Quality Control (Trimmomatic) and Mapping (STAR)
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

## <a href="https://github.com/hanielcedraz/BAQCOM/blob/47ef1813f68f6c79f51e59a126024ab5d6ce1b3f/RELEASE_notes.md">RELEASEnotes</a>
