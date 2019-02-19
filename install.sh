while getopts 'h' c;
do
  echo "help"
  case $c in
        h) ACTION= echo "#Use this script to change the trimmomatic path in ".qc_trimmomatic" and put theses file into the bash"

           exit
           ;;
  esac
done
shift $((OPTIND - 1))

#Use this script to change the trimmomatic path in R and put theses file into the bash



grep "$PWD" ~/.bash_profile > /dev/null
if [ $? -ne 0 ]; then
  cat ".qc_trimmomatic" | sed "s|XXX|$PWD|" > qc_trimmomatic.R
  chmod +x qc_trimmomatic.R
  echo -e "\n"PATH=$PATH:$PWD >> ~/.bash_profile;
  source ~/.bash_profile;
  
  mv qc_trimmomatic .qc_trimmomatic
  
fi

