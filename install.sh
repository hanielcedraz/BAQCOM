if [[ ( $@ == "--help") ||  $@ == "-h" ]];
    then
       echo "#Use this script to change the trimmomatic path in ".qc_trimmomatic" and put theses file into the bash"
       exit 0
    else
       echo "It is not a valid argment. Try ./install.sh -h or ./install.sh --help"
       exit 1
fi

grep "$PWD" ~/.bash_profile > /dev/null
if [ $? -ne 0 ]; then
  cat ".qc_trimmomatic" | sed "s|XXX|$PWD|" > qc_trimmomatic.R
  echo -e "\nPATH=\$PATH:$PWD:\n" >> ~/.bash_profile;
  source ~/.bash_profile;
  chmod +x qc_trimmomatic.R mapping_STAR.R .install_packages.R create_samples.sh;
  .install_packages.R;
else
  echo "It is already installed"
fi

 
