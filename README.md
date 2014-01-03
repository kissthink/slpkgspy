slpkgspy
========

This script finds, gets info and downloads Slackware packages.   
With search (-s) option, you can give a pattern as input.    
   
slpkgspy.sh -s alsa   

<pre>
[l]: alsa-lib-1.0.27.2-i486-1.txz (Advanced Linux Sound Architecture library)
[l]: alsa-oss-1.0.25-i486-1.txz (library/wrapper to use OSS programs with ALSA)
[ap]: alsa-utils-1.0.27.1-i486-1.txz (Advanced Linux Sound Architecture utilities)
[l]: libao-1.1.0-i486-1.txz (Audio Output library)
[l]: sdl-1.2.15-i486-1.txz (Simple DirectMedia Layer library)
</pre>

With info (-i) option and download (-d) options, you must specify the package's name.   

slpkgspy.sh -i alsa-lib-1.0.27.2-i486-1.txz   

<pre>   
PACKAGE NAME:  alsa-lib-1.0.27.2-i486-1.txz
PACKAGE LOCATION:  ./slackware/l
PACKAGE SIZE (compressed):  396 K
PACKAGE SIZE (uncompressed):  1790 K
PACKAGE DESCRIPTION:
alsa-lib: alsa-lib (Advanced Linux Sound Architecture library)
alsa-lib:
alsa-lib: The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI
alsa-lib: functionality to the Linux operating system.  This is the ALSA library
alsa-lib: (libasound) which is used by audio applications.
alsa-lib:
alsa-lib: For more information, see http://alsa-project.org
alsa-lib:
</pre>

You can also use input = ALL to search, get info and download all packages.   

IMPORTANT: into the script you must set two variables:    
1) MIRROR for your prefer mirror    
2) PKGDOWN where the packages will be downloaded   

