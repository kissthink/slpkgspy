# This script finds, gets info and downloads Slackware packages.
# With search (-s) option, you can give a pattern as input. 
# With info (-i) and download (-d) options, you must specify the package's name.
#
# Below an example for mplayer.
#
# Search a pkg:           slpkgspy.sh -s mplayer
# More info for a pkg:    slpkgspy.sh -i MPlayer-1.1_20120701-i486-2.txz 
# Download a pkg:         slpkgspy.sh -d MPlayer-1.1_20120701-i486-2.txz
#
# You can also use input = ALL to search, get info and download all packages.
#
# You must set two variables:
# 1) MIRROR for your prefer mirror 
# 2) PKGDOWN where the packages will be downloaded
#
# 01/01/2014 (2.0): added info (-i) and download (-d) options
# 18/12/2013 (1.4): fixed bug for pkg description
# 10/12/2013 (1.2): mktemp for tmp files 
# 24/07/2013 (1.0): released slpkgspy.sh
#
# Author: Emanuele Orlando (aka kooru)
# Copyright: (C) 2013-2014 
# License: GPLv3
#
#!/bin/bash

# MIRROR: set your prefer mirror 
MIRROR=ftp://ftp.slackware.no/slackware/slackware-14.1/slackware

# PKGDOWN: set the path where the packages will be downloaded 
PKGDOWN=/var/slpkgspy

######################## FUNCTION ########################

# Function usage
usage() {
  echo "Search a pkg:         slpkgspy.sh -s [pattern|pkg-name|ALL]"
  echo "More info for a pkg:  slpkgspy.sh -i [pkg-name|ALL]" 
  echo "Download a pkg:       slpkgspy.sh -d [pkg-name|ALL]"
}

pkglist() {

  # Download packages list
  wget -q -T 30 -t 1 -P $BUFF ${MIRROR}/$PACKAGES_LIST # download the list

  if [ $? -ne 0 ]; then # if wget gives errors or over 30 secs
    echo "Unable to connect to $MIRROR. Please verify if MIRROR exists and/or find $PACKAGES_LIST"
    exit 1;
  fi
}

search() {

  # Search package
  SCWD="$1"
  
  # Run pkglist
  pkglist

  if [ "$SCWD" = "ALL" ]; then # full packages list
    for pkg in $(cat ${BUFF}/$PACKAGES_LIST | tail -n+10 | grep "PACKAGE NAME" | awk -F ":" '{print $2}' | tr -d ' ' | sort | uniq)
    do 
        PAKLOC=$(cat ${BUFF}/$PACKAGES_LIST | grep -A 1 -w "$pkg" | tail -1 | sed 's/.*\/.*\///') # package type
        PAKABS=$(cat ${BUFF}/$PACKAGES_LIST | grep -A 5 -w "$pkg" | tail -n +6 | sed 's/[^(]*(\([^)]*\)).*/\1/') # package description

        # Print full packages list
        if [ -z "$PAKABS" ]; then
          echo "[$PAKLOC]: $pkg"
        else
          echo "[$PAKLOC]: $pkg ($PAKABS)"
        fi
 
    done 

  else # searching package from pattern

    for pkg in $(cat ${BUFF}/$PACKAGES_LIST | tail -n+10 | grep -i $SCWD | awk -F ":" '{print $1}' | grep -v PACKAGE | sort | uniq) 
    do
         cat ${BUFF}/$PACKAGES_LIST | grep "PACKAGE NAME:" | grep "$pkg" | awk -F "PACKAGE NAME:" '{print $2}' | tr -d ' ' >> $PAKTMP
    done

         if [ -z "$pkg" ]; then # if pkg is zero
           echo "${SCWD}: package not found!"
           exit
         fi

    for line in $(cat $PAKTMP | sort | uniq) 
    do
          
         PAKLOC=$(cat ${BUFF}/$PACKAGES_LIST | grep -A 1 -w "$line" | tail -1 | sed 's/.*\/.*\///') # package type
         PAKABS=$(cat ${BUFF}/$PACKAGES_LIST | grep -A 5 -w "$line" | tail -n +6 | sed 's/[^(]*(\([^)]*\)).*/\1/') # package description

         # Print package list found
         if [ -z "$PAKABS" ]; then
           echo "[$PAKLOC]: $line"
         else
           echo "[$PAKLOC]: $line ($PAKABS)"
         fi

    done

   fi
}

# Function info
info() {

  # Info package
  IPAK="$1" 

  # Run pkglist
  pkglist

  if [ "$IPAK" = "ALL" ]; then
    cat ${BUFF}/$PACKAGES_LIST # print info for all packages
  else
    PAKINFO=$(cat ${BUFF}/$PACKAGES_LIST | sed -n "/PACKAGE NAME:  ${IPAK}$/,/^$/p")
      if [ -z "$PAKINFO" ]; then
        echo "Package not found!"
      else
        echo "$PAKINFO" # print info package
      fi
  fi
}

# Function download
download() {

  # Download package
  MYPAK="$1"

  # Check if PKGDOWN is empty
  if [ -z $PKGDOWN ]; then
    echo "You must specify a path where packages can be downloaded"
    exit 1;
  fi

  # Create the path if it not exists
  [ ! -d $PKGDOWN ] && mkdir -p $PKGDOWN

  # Run pkglist
  pkglist

  PAKCHK=$(cat ${BUFF}/$PACKAGES_LIST | grep -w $MYPAK | awk -F ":" '{print $2}' | tr -d ' ')

  if [ "$MYPAK" = "$PAKCHK" ]; then
    MYPAKLOC=$(cat ${BUFF}/$PACKAGES_LIST | grep -A 1 -w "$MYPAK" | tail -1 | tail -1 | sed 's/.*\/.*\///') # package type
    wget -P $PKGDOWN ${MIRROR}/${MYPAKLOC}/$MYPAK # download package
  elif [ "$MYPAK" = "ALL" ]; then
    cat ${BUFF}/PACKAGES.TXT | grep "PACKAGE NAME:" | awk '{print $3}' >> $PAKTMP

      while read LINEPACK
      do
        MYPAKLOC=$(cat ${BUFF}/$PACKAGES_LIST | grep -A 1 -w "$LINEPACK" | tail -1 | tail -1 | sed 's/.*\/.*\///') # package type
        wget -P $PKGDOWN ${MIRROR}/${MYPAKLOC}/$LINEPACK # download ALL packages
      done < $PAKTMP 

  else
    echo "Package not found!"
  fi
}

######################## MAIN ########################

# Packages file
PACKAGES_LIST=PACKAGES.TXT

# Tmp path
BUFF=$(mktemp -d buff.XXXXXX)
PAKTMP=$(mktemp ${BUFF}/paktmp.XXXXXX)

# Only one input: your pattern or ALL
if [ $# -ne 2 ]; then
  usage
  exit 1
fi

if [ -z $MIRROR ]; then
  echo "You must specify a mirror!"
  exit 1
fi

case "$1" in
  "-s") search $2
      ;;
  "-i") info $2
      ;;
  "-d") download $2
      ;;
    *) usage
      ;;
esac

# Delete buffer
rm -r $BUFF

