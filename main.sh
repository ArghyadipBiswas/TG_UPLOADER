#!/bin/bash
if [ -d $PWD/dl ];
then 
    sudo rm -rf $homedir/dl
fi
clear
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
    TRACKERS=$(curl -Ns https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_udp.txt | awk '$1' | tr '\n' ',')
    aria2c --allow-overwrite=true --bt-enable-lpd=true --bt-max-peers=0 --bt-tracker="[$TRACKERS]" --check-certificate=false --follow-torrent=mem --max-connection-per-server=16 --max-overall-upload-limit=1K --peer-agent=qBittorrent/4.3.6 --peer-id-prefix=-qB4360- --seed-time=0 --bt-tracker-connect-timeout=300 --bt-stop-timeout=1200 --user-agent=qBittorrent/4.3.6 -d $DownloadDir $link
fi
clear
cd dl
filename=$(find "$PWD/" -maxdepth 1 -type f -printf "%f")
filesize=$(stat -c %s *.zip)
cd ..
if [ $filesize -gt 2097152000 ];
then
        cd dl
        echo "File is bigger than 2000MB . Splitting..."
        split -d -b 2000M "$PWD/$filename" $filename
        loop=$(ls | wc -l)
        cd ..
        loop=$(($loop-1))
        a=0
        while [ $a -lt $loop ]
        do
            python3 up.py $PWD/dl/*0$a
            ((a++))
        done
else
        echo "no need to split! Uploading..."
        filename=$(find "$PWD/dl/" -maxdepth 1 -type f -printf "%f")
        python3 up.py $filename
fi


rm -rf $PWD/dl
