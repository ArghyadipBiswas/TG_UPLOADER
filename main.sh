#!/bin/bash
#######clean download directory##########
clear
if [ -d $PWD/dl ];
then 
    sudo rm -rf $PWD/dl
fi
########Downloading######
read -p "Enter link : " link
if [[ $link != "https://"* ]];
then
    echo "Not a link! Exiting..."
    exit
elif [[ $link == "https://drive.google.com/"* ]];
then
    echo "Gdrive Link Detected! Downloading..."
    gdown $link
else
    echo "Normal Link Detected! Downloading..."
    TRACKERS=$(curl -Ns https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_udp.txt | awk '$1' | tr '\n' ',')
    aria2c --allow-overwrite=true --bt-enable-lpd=true --bt-max-peers=0 --bt-tracker="[$TRACKERS]" --check-certificate=false --follow-torrent=mem --max-connection-per-server=16 --max-overall-upload-limit=1K --peer-agent=qBittorrent/4.3.6 --peer-id-prefix=-qB4360- --seed-time=0 --bt-tracker-connect-timeout=300 --bt-stop-timeout=1200 --user-agent=qBittorrent/4.3.6 -d $PWD/dl/ $link
fi
#########check file size########
clear && cd dl
filename=$(find "$PWD/" -maxdepth 1 -type f -printf "%f")
filesize=$(stat -c %s *.zip)

if [ $filesize -ge 2097152000 ];
then
    echo "File is larger than 2000MB! Splitting..."
    split -d -b 2000M "$PWD/$filename" $filename
    loop=$(ls | wc -l)
    cd ..
    loop=$(($loop-1))
    echo "Starting Upload..."
    a=0
    while [ $a -lt $loop ]
    do
        python3 up.py $PWD/dl/*0$a
        ((a++))
    done
else
    echo "No need to split! Uploading..."
    python3 up.py $PWD/dl/$filename
fi
rm -rf $PWD/dl
