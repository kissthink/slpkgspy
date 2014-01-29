# slpkgspy.sh
#
# Author: Emanuele Orlando (aka kooru)
# Copyright: (C) 2013-2014 
# License: GPLv3
#
# 29/01/2014 (3.0): added SSA functions (-a, -k)
#                   added Url function (-u)
#                   fixed bug on TMP  
#                   improved the syntax
# 12/01/2014 (2.2): minor bugfix for pkg with no desc
# 03/01/2014 (2.0): added info (-i) and download (-d) options
# 18/12/2013 (1.4): fixed bug for pkg description
# 10/12/2013 (1.2): mktemp for tmp files 
# 24/07/2013 (1.0): released slpkgspy
#
#!/bin/sh

# Version
VERSION="3.0"

# Check for root
if [ $(id -u) -ne 0 ]; then
  echo "You must be root!"
  exit 1
fi

##### Personal Settings ##### 
# The url must point to the folder including PACKAGES.TXT 
# and packages series (a, ap, d, etc)
MIRROR=ftp://ftp.slackware.no/slackware/slackware-14.1/slackware

# The path where the packages will be downloaded 
PKGDOWN=/var/slpkgspy
#############################

######################## FUNCTION ########################

###### Function usage ######
usage() {
  echo "--slpkgspy $VERSION--"
  echo "-a [year]: print the security advisories list"
  echo "-d [pkg-name|ALL]: download a package"
  echo "-i [pkg-name|ALL]: print info for a package"
  echo "-k [ssacode]: print info for a SSA package"
  echo "-s [pattern|pkg-name|ALL]: seach a package"
  echo "-u [url]: download a package from a url"
}
############################

##### Function pkglist #####
pkglist() {
  # Download packages list
  wget -q -T 30 -t 1 -P $TMP ${MIRROR}/$PACKAGES_LIST # download the list

  if [ $? -ne 0 ]; then # with errors or over 30 secs
    echo "Unable to connect to $MIRROR. Please verify if MIRROR exists and/or find $PACKAGES_LIST"
    exit 1
  fi
}
############################

###### Function search #####
search() {

  # Check for special charcters 
  echo "$1" | grep -q "[A-Z]\|[a-z]\|[0-9]\|-\|."

  if [ $? -ne 0 ]; then
    echo "Please not use special characters as '[' or '?')"
    exit 1
  fi

  # Search package
  SCWD="$1"
  
  # Run pkglist
  pkglist

  if [ "$SCWD" = "ALL" ]; then # full packages list
    for pkg in $(cat ${TMP}/$PACKAGES_LIST | sed -n 's/PACKAGE NAME:  \(.*\)/\1/p')
    do 
        PAKLOC=$(cat ${TMP}/$PACKAGES_LIST | grep -A 1 -w "$pkg" | tail -1 | sed 's/.*\/.*\///') # package type
        PAKABS=$(cat ${TMP}/$PACKAGES_LIST | grep -A 5 -w "$pkg" | tail -n +6 | sed -e 's/.*: \(.*\)/\1/' -e 's/[^(]*(\(.*\)).*/\1/') # package description

        # Print full packages list
        if [ -z "$PAKABS" ]; then
          echo "[$PAKLOC]: $pkg"
        else
          echo "[$PAKLOC]: $pkg ($PAKABS)"
        fi
 
    done 

  else # searching package from pattern

    for pkg in $(cat ${TMP}/$PACKAGES_LIST | grep -i "$SCWD" | awk -F ":" '{print $1}' | grep -v PACKAGE | sort | uniq) 
    do
         cat ${TMP}/$PACKAGES_LIST | sed -n "s/PACKAGE NAME:  \(.*$pkg.*\)/\1/p" >> $PAKTMP # tmp list
    done

    for pkg in $(cat ${TMP}/$PACKAGES_LIST | sed -n "s/PACKAGE NAME:  \(.*$SCWD.*\)/\1/p" | sort | uniq)
    do
         echo "$pkg" >> $PAKTMP # tmp list
    done

         if [ ! -s $PAKTMP ]; then # if pkg is zero
           echo "${SCWD}: package not found!"
           exit
         fi

    for line in $(cat $PAKTMP | sort | uniq) 
    do
          
         PAKLOC=$(cat ${TMP}/$PACKAGES_LIST | grep -A 1 -w "$line" | tail -1 | sed 's/.*\/.*\///') # package type
         PAKABS=$(cat ${TMP}/$PACKAGES_LIST | grep -A 5 -w "$line" | tail -n +6 | sed -e 's/.*: \(.*\)/\1/' -e 's/[^(]*(\(.*\)).*/\1/') # package description

         # Print package list found
         if [ -z "$PAKABS" ]; then
           echo "[$PAKLOC]: $line"
         else
           echo "[$PAKLOC]: $line ($PAKABS)"
         fi

    done

   fi
}
############################

####### Function info ######
info() {
  # Info package
  IPAK="$1" 

  # Run pkglist
  pkglist

  if [ "$IPAK" = "ALL" ]; then
    cat ${TMP}/$PACKAGES_LIST | tail -n+10 # print info for all packages
  else
    PAKINFO=$(cat ${TMP}/$PACKAGES_LIST | sed -n "/PACKAGE NAME:  ${IPAK}$/,/^$/p")
      if [ -z "$PAKINFO" ]; then
        echo "Package not found!"
      else
        echo "$PAKINFO" # print info package
      fi
  fi
}
############################

##### Function download ####
download() {
  # Download package
  MYPAK="$1"

  # Run pkglist
  pkglist

  PAKCHK=$(cat ${TMP}/$PACKAGES_LIST | grep -w $MYPAK | awk -F ":" '{print $2}' | tr -d ' ')

  if [ "$MYPAK" = "$PAKCHK" ]; then
    MYPAKLOC=$(cat ${TMP}/$PACKAGES_LIST | grep -A 1 -w "$MYPAK" | tail -1 | sed 's/.*\/.*\///') # package type
    wget -P $PKGDOWN ${MIRROR}/${MYPAKLOC}/$MYPAK # download package
  elif [ "$MYPAK" = "ALL" ]; then
    cat ${TMP}/PACKAGES.TXT | grep "PACKAGE NAME:" | awk '{print $3}' >> $PAKTMP

      while read LINEPACK
      do
        MYPAKLOC=$(cat ${TMP}/$PACKAGES_LIST | grep -A 1 -w "$LINEPACK" | tail -1 | sed 's/.*\/.*\///') # package type
        wget -P $PKGDOWN ${MIRROR}/${MYPAKLOC}/$LINEPACK # download ALL packages
      done < $PAKTMP 

  else
    echo "Package not found!"
  fi
}
############################

##### Function seclist #####
seclist() {
  # The years accepted are only the corrent one
  # and "current - 1"
  YEAR1=$(date +%Y)
  YEAR2=$(($YEAR1-1))
 
  # Check if the input is correct 
  if [ -z $(echo $1 | grep "^20[0-9][0-9]$") ]; then
    echo "Please insert a correct year (20YY)!"
    exit 1
  elif [ $1 -ne $YEAR1 -a $1 -ne $YEAR2 ]; then
    echo "The years accepted are only the corrent one and 'current - 1'"
    exit 1
  fi
 
  # Url
  URLBASE="http://www.slackware.com/security/"
  URLIST="list.php?l=slackware-security&y="
   
  # Download Slackware security webpage
  wget -q -T 30 -t 1 -P $TMP "${URLBASE}${URLIST}${1}" # download the page

  if ! grep "SSA:" "${TMP}/${URLIST}${1}" > /dev/null; then # with errors or over 30 secs
    echo "Unable to connect to ${URLBASE}${URLIST}${YEAR}. Please verify if the url is correct"
    exit 1
  fi

  # Print the list
  tac "${TMP}/${URLIST}${1}" | grep "(SSA:" | sed -e 's/.*\(20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] - .*\)/\1/' | sed -e 's/<.*>//'
}
############################

##### Function secinfo #####
secinfo() {

  # Same thing as in function seclist 
  YEAR1=$(date +%Y)
  YEAR2=$(($YEAR1-1))

  # Check if SSA code is correct
  if [ -z $(echo $1 | grep "^20[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9]$") ]; then
    echo "The SSA code is not correct!"
    exit 1
  fi

  # Extract year from SSA code
  YEAR=$(echo $1 | awk -F "-" '{print $1}')
  
  # Check the year
  if [ $YEAR -ne $YEAR1 -a $YEAR -ne $YEAR2 ]; then
    echo "Your SSA code seems too old"
    exit 1
  fi

  # Url
  URLBASE="http://www.slackware.com/security/"
  URLIST="list.php?l=slackware-security&y="

  # Download Slackware security webpage
  wget -q -T 30 -t 1 -P $TMP "${URLBASE}${URLIST}${YEAR}" # download the page

  # Find and Download the page for the specific SSA code
  URLINFO=$(cat "${TMP}/${URLIST}${YEAR}"  | grep $1 | sed 's/.*A HREF="\(.*\)".*/\1/')
  wget -q -T 30 -t 1 -P $TMP "${URLBASE}${URLINFO}"

  if [ ! -f ${TMP}/${URLINFO} ]; then
    echo "Impossible download the webpage for $1 code"
    exit 1
  fi

  # Print the info
  cat ${TMP}/${URLINFO} | sed -n '/BEGIN PGP/,/END PGP/p'
}
############################

##### Function downurl #####
downurl() {
  
  # Url 
  URL=$1

  wget -T 30 -t 1 -P $PKGDOWN "${URL}" # download the pkg 
}
############################

######################## MAIN ########################

# Clean TMP if still exists 
rm -r /tmp/buff-sl* 2> /dev/null

# Packages file
PACKAGES_LIST=PACKAGES.TXT

# Tmp path
TMP=$(mktemp -d /tmp/buff-sl.XXXXXX)
PAKTMP=$(mktemp ${TMP}/paktmp.XXXXXX)

# Only one input: your pattern or ALL
if [ $# -ne 2 ]; then
  usage
  exit 1
fi

if [ -z $MIRROR ]; then
  echo "You must specify a mirror!"
  exit 1
fi

# Check if PKGDOWN is empty
if [ -z $PKGDOWN ]; then
  echo "You must specify a path where the packages can be downloaded"
  exit 1
fi

# Create the path if it not exists
if [ ! -d $PKGDOWN ]; then
  mkdir -p $PKGDOWN 
fi

case "$1" in
  "-s") search $2
      ;;
  "-i") info $2
      ;;
  "-d") download $2
      ;;
  "-a") seclist $2
      ;;
  "-k") secinfo $2
      ;;
  "-u") downurl $2
      ;;
    *) usage
      ;;
esac

# Delete TMP
rm -r $TMP
