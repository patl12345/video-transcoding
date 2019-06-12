#!/bin/bash

#make sure another copy isn't running
if pgrep -x "transcodeVideo" > /dev/null
then
    exit 0
fi

#find $REMOTE_DIR -type f \( -iname '*.ts' -or  -iname '*.mkv'  -or  -iname '*.mp4' -not -iname '*-trailer.*' \)


LOCAL_DIR="/data"
REMOTE_DIR="/movies"

#loop forever
while :; do

    #if the transcode list is empty or missing build a new list
    if [ ! -s /data/to_be_transcoded.txt ]; then
        touch /data/to_be_transcoded.txt
        find $REMOTE_DIR -type f \( -iname '*.ts' -or  -iname '*.mkv'  -or  -iname '*.mp4' \) |  grep -v 'trailer\|NEW' | while read line; do     
            filename=$(basename "$line")
            extension="${filename##*.}"
            filename="${filename%.*}"
            remoteDir=$(dirname "$line")
            
            if [ -f "$remoteDir/compressed" ]; then
                echo "ignoring $line, found compressed"
                continue
            elif [ -f "$remoteDir/$filename.compressed" ]; then
                echo "ignoring $line, found $filename.compressed"
                continue
            fi

            echo $line >> /data/to_be_transcoded.txt
        done
    fi

    #process until we've emptied the file
    while [ -s /data/to_be_transcoded.txt ]; do
        
        #transcode the top file in the transcode list file
        file=$(head -n 1 /data/to_be_transcoded.txt)
        filename=$(basename "$file")
        extension="${filename##*.}"
        filename="${filename%.*}"
        remoteDir=$(dirname "$file")

        echo "Processing file '$file'"; 

        localSrcFile=$LOCAL_DIR/$filename.$extension
        localTargetFile=$LOCAL_DIR/$filename-NEW.$extension
        remoteTargetFile=$remoteDir/$filename-NEW.$extension
        remoteTagFile=$remoteDir/$filename.compressed

        #copy file locally
        cp $file $localSrcFile

        #transcode
        echo "" | transcode-video --preset faster --quick $localSrcFile -o $localTargetFile #note, the echo is to stop tv hijacking stdin and stopping the loop

        #copy file back to nfs
        cp $localTargetFile $remoteTargetFile

        #mark as processed
        touch $remoteTagFile

        #remove the movie from the file
        tail -n +2 "/data/to_be_transcoded.txt" > "/data/to_be_transcoded.tmp" && mv  "/data/to_be_transcoded.tmp" "/data/to_be_transcoded.txt"
    done;
    
    sleep 1d
done;
