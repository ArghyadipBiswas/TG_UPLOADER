#!/bin/bash
mkdir dl && chmod 777 dl
DownloadDir="$PWD/dl/"
read link
echo $link
if [[ $link != "https://"* ]]; then
    echo "Not a valid link! Retry"
    exit
elif [[ $link == "https://drive.google.com/"* ]]; then
    echo "Gdrive link Detected . Starting Download ."
    gdown "$link" -O $DownloadDir
else
    aria2c --max-connection-per-server=16 -d $DownloadDir $link
fi

filesize=$(stat -c %s *.zip)
if [ $filesize -gt 2097152000 ];
then
        echo "File is bigger than 2000MB . Splitting..."
        filename=$(find "$PWD/dl/" -maxdepth 1 -type f -printf "%f")
        split -d -b 2000M "$PWD/dl/$filename" $filename
else
        echo "no need to split! Uploading..."
fi

loop=$(ls | wc -l)
loop=$(($loop-1))
a=0
while [ $a -lt $loop ]
do
    python3 up.py $PWD/dl/*0$a
    ((a++))
done
