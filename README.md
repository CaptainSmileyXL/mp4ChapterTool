# mp4ChapterTool

Introduction:
-------------
This is a shell script used to analyze video files that don't have chapters, looking 
for logical places to add a chapter.

It uses ffmpeg to analyze the video for logical breaks.  It can output a screenshot
for each location found for review.  The script can also generate a metadata file 
and insert the times found during the analysis.  The user can also modify metadata file
and use it later for chapter modification.


Supported Platforms
-------------------
```
Tested on Mac OS X 10.14.6 - should work with litte modification on other systems
```

Requirements:
-------------------
```
ffmpeg (http://www.ffmpeg.org)
```

Usage:
------
```
I recommend you make the script executable (chmod 755 mp4chaptertool.sh) then you can:  
./mp4chaptertool.sh <video file>  
```
