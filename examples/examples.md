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
