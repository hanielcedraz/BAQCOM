#!/usr/bin/env bash


usage() {
    cat <<EOF
Usage: $0 [options] -- createSample version 0.3.0

    Use this script to create a sample ID file.

Arguments:
  -d <val>
    Specify the folder which is storage the fastq files. [default: 00-Fastq].

  -f <val>
    Specify if files are pair ou single-end, and create a samples file using these files. [default: pair-end].

EOF
}



# handy logging and error handling functions
log() { printf '%s\n' "$*"; }
error() { log "ERROR: $*" >&2; }
fatal() { error "$*"; exit 1; }
usage_fatal() { error "$*"; usage >&2; exit 1; }

# parse options

filetype="pair"
dir="00-Fastq"
#single="single"
while [ "$#" -gt 0 ]; do
    arg=$1
    case $1 in
        # convert "--opt=the value" to --opt "the value".
        # the quotes around the equals sign is to work around a
        # bug in emacs' syntax parsing
        --*'='*) shift; set -- "${arg%%=*}" "${arg#*=}" "$@"; continue;;
        -d) shift; dir=$1;;
        -f) shift; filetype=$1;;
        -h|--help) usage; exit 0;;
        --) shift; break;;
        -*) usage_fatal "unknown option: '$1'";;
        *) break;; # reached the list of file names
    esac
    shift || usage_fatal "option '${arg}' requires a value"
done



#Creating samples_file.txt
file="samples.txt"
rm -f $file

#dir="00-Fastq"

pair.end.function() {
if [ -d "$dir" ]
then
    echo "Creating samples file using Pair-End files"
    if [ "$(ls -A $dir)" ]
    then
            cd $dir
            echo -e 'SAMPLE_ID\tRead_1\tRead_2' > ../samples.txt
            paste <(ls *_R1_001.fastq.gz | cut -d "_" -f1) <(ls *_R1_001.fastq.gz) <(ls *_R2_001.fastq.gz) >> ../samples.txt
            cd ..
            echo -e "\033[1;31m Samples_File ($file) successfully created"
            echo -e "\033[0m"
    else
            echo -e "\033[1;31m $dir exist but is empty"
            echo -e "\033[0m"
    fi
else
        echo -e "\033[1;31m $dir not found. Make sure that $dir exist"
        echo -e "\033[0m"
fi
}

single.end.function() {
if [ -d "$dir" ]
#if [ -d "$(ls -A "$dir")" ]
then
    echo "Creating samples file using single-end files"
    if [ "$(ls -A $dir)" ]
    then
            cd $dir
            echo -e 'SAMPLE_ID\tRead_1' > ../samples.txt
            paste <(ls *_R1_001.fastq.gz | cut -d "_" -f1) <(ls *_R1_001.fastq.gz) >> ../samples.txt
            cd ..
            echo -e "\033[1;31m Samples_File ($file) successfully created"
            echo -e "\033[0m"
    else
            echo -e "\033[1;31m $dir exist but is empty"
            echo -e "\033[0m"
    fi
else
        echo -e "\033[1;31m $dir not found. Make sure that $dir exist"
        echo -e "\033[0m"
fi
}



if [ "$filetype" == "pair" ];
then
    pair.end.function
elif [ "$filetype" == "single" ];
then
    single.end.function
fi
