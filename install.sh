while getopts 'h' c;
then
  echo "help"
  case $c in
        h) ACTION= echo "#Use this script to change the trimmomatic path in ".qc_trimmomatic" and put theses file into the bash"

           exit
  stop         
           ;;
  esac
done
shift $((OPTIND - 1))



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

 
