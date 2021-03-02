#!/bin/sh


##  Author: CaptainSmiley
##  Date:   2/26/2021
##  License:    Creative Commons Zero v1.0 Universal

##  this script is designed to find and add chapters to videos where there
##  are none (such as compilation videos).  It will analyze input videos
##  looking for breaks where chapters could be.  It can create the proper
##  metadata file for chapter creation.  You can edit this file manually
##  and have the script create a new video file with the added chapters.


function convert_time {
    local T=$1
    local t=${T%.*}
    local s=$((t%60))
    local m=$((t/60%60))
    local h=$((t/60/60))

    printf '%d:%02d:%06.3f\n' $h $m $s.$f
}


function create_chapters {
    local input="./timestamps.txt"
    local outfile="./metadata.txt"
    local pass=0
    local prevtime=0

    while IFS= read -r line
    do
        if [ $pass -eq 0 ]
        then
            prevtime=$line
            pass=1
        else
            endtime=`bc -l <<< "$line-0.001"`
            start="\n[CHAPTER]\nTIMEBASE=1/1\nSTART=$prevtime\nEND=$endtime"
            prevtime=$line
            echo "$start\n" >> $outfile
        fi
    done < "$input"
}

##  =======================================================================================
##  script start


echo
echo "MP4 Chapter Creation Tool"
echo "Version 0.1"
echo

if [ $# -eq 0 ]
then
    echo "Usage: $0 <name of video file>"
    exit 1
fi

echo "Analyzing file: $1"
ffmpeg -i $1 -filter:v "select='gt(scene,0.4)',metadata=print:file=showinfo.txt" -vsync vfr img%03d.png 
grep pts_time:[0-9.]* showinfo.txt -o | grep -E '[0-9]+(?:\.[0-9]*)?' -o > timestamps.txt
rm showinfo.txt

##  images are the screenshot of the begining of each chapter found
##  select yes if you want to review the images after the script is done
echo
echo
echo "Do you want to keep the images? [y/N]"
read keepImages
if [ "$keepImages" == "N" ] || [ -z "$keepImages" ] || [ "$keepImages" == "n" ]
then
    rm *.png
fi

##  the metadata file (metadata.txt) file contains the data needed for
##  chapter creation.  Selecting yes will create a new metadata file.
##  Selecting no will use an existing metadata file 
echo
echo "Do you need a chapter metadata file? [y/N]"
read metaFile
if [ "$metaFile" == "y" ] || [ "$metaFile" == "Y" ]
then
    ffmpeg -i $1 -f ffmetadata metadata.txt
    create_chapters
fi

##  if you do not want to create the chapters, select no.  Selecting
##  yes will tell the script to use the metadata.txt file to create 
##  chapters from the video specified, but will output the modified 
##  version as 'output.mp4'
echo
echo "Do you want to create chapters in video? [y/N]"
read writeChapters
if [ "$writeChapters" == "y" ] || [ "$writeChapters" == "Y" ]
then
    echo "Writting metadata"
    ffmpeg -i $1 -i metadata.txt -map_metadata 1 -codec copy output.mp4
    echo "\n\nNew file with chapters:  output.mp4"
fi

##  remove temporary file
rm timestamps.txt
echo "Done!"
