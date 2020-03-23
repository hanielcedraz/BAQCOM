
## BAQCOM - Bioinformatics Analysis for Quality Control and Mapping <br>
### Quality Control (Trimmomatic), Mapping (STAR | HISAT2) and Counting Reads (HTSeq | featuresCount)
<br>
<br>

BAQCOM is an user-friendly pipeline which implements five automated pipelines for RNA-Seq analysis using Trimmomatic for QC, STAR or HISAT2 for mapping and, HTSeq or featuresCount for counting reads.
<br>
<br>
<br>

<a href="https://ibb.co/tsTGtSf"><img src="https://i.ibb.co/gTL2pG1/baqcom-steps-white.png" alt="baqcom-steps-white" border="0" width="900"></a>




## STEP.1 - Download this repository to a preference path:<br>
Git is required
```bash
 $ git clone https://github.com/hanielcedraz/BAQCOM.git
 $ cd BAQCOM
 $ chmod +x install.sh
 $ ./install.sh
 ```
<br>
<br>

## STEP.2 - Install R<br>
   To install R Access <a href="https://cran.r-project.org">CRAN website </a>
<br>
<br>

## STEP.3 - Install MultiQC and HTSeq-count:
MultiQC:
If you would like to use multiqc analysis, please install it.<br>
Installation:
If pip is not installed, please install as follow:
```bash
	$ wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
	$ python get-pip.py
```    
You can install MultiQC from PyPI using pip as follow:
```bash
	$ pip install multiqc
```
More information, please access <a href="https://github.com/ewels/MultiQC"> MultiQC website</a>
	
	
HTSeq-count: <br>
```markdown
HTSeq is available from the Python Package Index (PyPI):
	To use HTSeq, you need Python 2.7 or 3.4 or above (3.0-3.3 are not supported), together with:
		NumPy, a commonly used Python package for numerical calculations
		Pysam, a Python interface to samtools. 
	To make plots you will need matplotlib, a plotting library. 
```
You can install HTSeq-count using pip:
```bash
	$ pip install HTSeq
```
<a href="https://htseq.readthedocs.io/en/release_0.11.1/install.html">or following the source documentation</a>
	
	
	
<br>
<br>

## STEP.4 - Install PigZ:
To speed up your analysis results, install the pigz.
Centos
```bash
$ sudo yum install pigz
```
Ubuntu
```bash
$ sudo apt install pigz
```
<br>
<br>
<br>

## Examples
You can find some command line examples <a href="https://github.com/hanielcedraz/BAQCOM/blob/master/examples/examples.md">here</a>
<br>
<br>
<br>
## Differential Expression Gene
You will find some script to analyze differential expression genes <a href="https://github.com/hanielcedraz/DiffExpressGenes.git">here</a>


## <a href="https://github.com/hanielcedraz/BAQCOM/blob/master/RELEASE_notes.md">RELEASEnotes</a>
