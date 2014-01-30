slpkgspy
========

This tool finds, gets info and downloads Slackware packages.   
In addition it gets info about the security advisories.   
The options are:    

<pre>
-a [year]: print the security advisories list
-d [pkg-name|ALL]: download a package
-i [pkg-name|ALL]: print info for a package
-k [ssacode]: print info for a SSA package
-s [pattern|pkg-name|ALL]: seach a package
-u [url]: download a package from a url
</pre>


With search (-s) option, you can give a pattern as input.    
   
slpkgspy.sh -s alsa   

<pre>
&#91;l]: alsa-lib-1.0.27.2-i486-1.txz (Advanced Linux Sound Architecture library)
&#91;l]: alsa-oss-1.0.25-i486-1.txz (library/wrapper to use OSS programs with ALSA)
&#91;ap]: alsa-utils-1.0.27.1-i486-1.txz (Advanced Linux Sound Architecture utilities)
&#91;l]: libao-1.1.0-i486-1.txz (Audio Output library)
&#91;l]: sdl-1.2.15-i486-1.txz (Simple DirectMedia Layer library)
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

With check security advisories (-a) option, you must specify the year.   
For clear reasons, only the corrent year and 'current - 1' year are accepted.   

slpkgspy.sh -a 2014    

<pre>
2014-01-13 - [slackware-security]  libXfont (SSA:2014-013-01)
2014-01-13 - [slackware-security]  openssl (SSA:2014-013-02)
2014-01-13 - [slackware-security]  php (SSA:2014-013-03)
2014-01-13 - [slackware-security]  samba (SSA:2014-013-04)
2014-01-28 - [slackware-security]  bind (SSA:2014-028-01)
2014-01-28 - [slackware-security]  mozilla-nss (SSA:2014-028-02)
</pre>

With info SSA package (-k) option, you must specify the SSA code.   

slpkgspy.sh -k 2014-028-02

(you will see the same output that you see on the webpage for that SSA).    

With url (-u) option, you must specify the direct url of the package.    

slpkgspy.sh -u ftp://ftp.slackware.com/pub/slackware/slackware-14.1/patches/packages/mozilla-nss-3.15.4-i486-1_slack14.1.txz    

IMPORTANT: into the script you must set two variables:    
1) MIRROR for your prefer mirror    
2) PKGDOWN where the packages will be downloaded   

