#
# BAQCOM 0.1.1 - 02/20/2019 
  Pipeline released

 ### baqcom_mapping Version 0.1.2 - 03/11/2019 
  Changed genomeDir parameter in baqcom_mapping. Now does not need to indicate the genome index path. The default is the same path to gtf_target.

 ### baqcom_qc Version 0.1.2 - 03/11/2019 
  added FastQC plots



#
# BAQCOM Version 0.2.0 - 03/19/2019 
 ### baqcom_mapping Version 0.2.0 - 03/19/2019 
  Now you can run samples in parallel 

 ### baqcom_qc Version 0.2.0 - 03/21/2019 
  Now you can run samples in parallel 

 ### baqcom_qc and baqcom_mapping Version 0.2.1 - 04/11/2019 
  Including multiqc analysis 

 ### baqcom_qc Version 0.2.2 - 04/15/2019 
  Including two more options on trimming: LEADING and TRAILING <br>
  Including pigz option

 ### baqcom_mapping Version 0.2.2 - 04/22/2019 
  Including stranded options 
  

 ### baqcom_qc and baqcom_mapping Version 0.2.3 - 04/23/2019 
  Change the folder names pattern <br>
  Set up pigz as default of compressed files <br>
  Minor bugs fixed
  

 ### baqcom_mapping Version 0.2.4 - 05/20/2019 
  Change requirements to genome generate, mapping and counting <br>
  Set up more parameters <br>
  Minor bugs fixed
  


#
# BAQCOM 0.3.0 - 07/20/2019

### baqcomSTARmapping
  Change pattern folder names <br>
    Minor bugs fixed
  
### baqcomTrimmomatic 
  Change pattern folder names <br>
  Minor bugs fixed
  
### baqcomHisat2Mapping 
  release of a new pipeline to align sequences
  
### baqcomFeaturesCount 
  release of a new pipeline to count reads 
  
### baqcomHtseqCounting 
  release of a new pipeline to count reads 
  
  <br>
  <br>
  <br>
  <br>
  <br>
  
  
  
#
# BAQCOM 0.3.1 - 07/26/2019

### baqcomSTARmapping
  single-end analysis implemented  <br>
    Minor bugs fixed
  
### baqcomTrimmomatic 
  single-end analysis implemented  <br>
  Minor bugs fixed
  
### baqcomHisat2Mapping 
  single-end analysis implemented 
  
### baqcomFeaturesCount 
  single-end analysis implemented <br>
  Count reads using Star results
  
### baqcomHtseqCounting 
  single-end analysis implemented 
  
  <br>
  <br>
  <br>
  <br>
  <br>  

  
  
  
#
# BAQCOM 0.3.2 - 08/08/2019

### baqcomSTAR
   Change the pipeline's name pattern <br>
    from baqcomSTARmapping.R to baqcomSTAR.R <br>
   Minor bugs fixed
  
### baqcomTrimmomatic 
   Minor bugs fixed
  
### baqcomHisat2Mapping 
  Change the pipeline's name pattern <br>
   from baqcomHisat2Mapping.R to baqcomHisat2.R <br>
  Minor bugs fixed
  
### baqcomFeaturesCount 
  Change the pipeline's name pattern <br>
   from baqcomFeaturesCount.R to baqcomFeatureCounts.R <br>
  Minor bugs fixed
  
### baqcomHtseqCounting 
  Change the pipeline's name pattern <br>
   from baqcomHtseqCounting.R to baqcomHtseq.R <br>
  Minor bugs fixed 
  
  <br>
  <br>
  <br>
  <br>
  <br>  
 
 # BAQCOM 0.3.3 - 10/24/2019
  ### baqcomSTAR
  Changing single-end files pattern as input  <br>
  baqcomSTAR now uses compressed fasta files (saving space on your disk) <br>
    Minor bugs fixed
  
  ### baqcomTrimmomatic 
  Changing single-end files pattern as input ans output  <br>
  Minor bugs fixed
  
  ### baqcomHisat2 
  Changing single-end files pattern as input <br>
  baqcomHisat2 now uses compressed fasta files (saving space on your disk) <br>
  Minor bugs fixed
  
  
 # BAQCOM 0.3.4 - 01/09/2020
  ### baqcomSTAR
  baqcomSTAR now uses compressed annotation files (saving space on your disk) <br>
  Minor bugs fixed


 # BAQCOM 0.3.5 - 11/03/2020
  Coding refactoring and update STAR version for baqcomSTAR <br>
  Update of Hisat2 version on baqcomHisat2 <br>
  Update htseq-count version on baqcomHtseq for multithreads <br>
  Minor bugs fixed <br>
