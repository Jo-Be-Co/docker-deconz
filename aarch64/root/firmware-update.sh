#!/bin/bash

VERSION=0.5
FLASHER=/usr/bin/GCFFlasher_internal
FW_PATH=/usr/share/deCONZ/firmware/
FW_BASE=http://deconz.dresden-elektronik.de/deconz-firmware/

echo "-------------------------------------------------------------------"
echo " "
echo "             marthoc/deconz Firmware Flashing Script"
echo " "
echo "                       Version: $VERSION"
echo " "
echo "-------------------------------------------------------------------"
echo " "
echo " "
echo "Listing attached devices..."
echo " "

$FLASHER -l

echo " "
echo "Enter the full device path, or press Enter now to exit."
echo " "
read -p "Device Path : " deviceName

if [[ -z "${deviceName// }" ]]; then
        echo "Exiting..."
        exit 1
fi

echo " "
echo "-------------------------------------------------------------------"
echo " "
echo "Firmware available for flashing:"
echo " "

ls -1 "$FW_PATH"

echo " "
echo "Enter the firmware file name from above, including extension."
echo "Alternetivly you may enter the name of a firmware file to download"
echo "from $FW_BASE"
echo "Simply press Enter now to exit."
echo " "

read -p "File Name : " fileName
echo " "
if [[ -z "${fileName// }" ]]; then
        echo "Exiting..."
        exit 1
fi
filePath="${FW_PATH%/}/$fileName"
if [[ ! -f $filePath ]]; then
        echo "File does not exist. Trying download."
        read -p "Enter Y to proceed, any other entry to exit: " answer
        echo " "
        if [[ $answer != [yY] ]]; then
                echo "Exiting..."
                exit 1
        fi
        echo "Downloading..."
        echo " "
        curl -o "$filePath" "${FW_BASE%/}/$fileName"
        retVal=$?
        if (( retVal != 0 )); then
                echo " "
                echo "Download Error! Please re-run this script..."
                echo " "
                exit $retVal
        fi
        echo " "
        echo "Download complete! Checking md5 checksum:"
        md5=$(curl -s "${FW_BASE%/}/${fileName}.md5")
        echo "${md5% *} ${filePath}" | md5sum --check
        echo " "
fi

echo "-------------------------------------------------------------------"
echo " "
echo "Device: $deviceName"
echo " "
echo "Firmware File: $fileName"
echo " "
echo "Are the above device and firmware values correct?"
read -p "Enter Y to proceed, any other entry to exit: " correctVal
echo " "

if [[ $correctVal == [yY] ]]; then
        echo "Flashing..."
        echo " "
        $FLASHER -d $deviceName -f "$filePath"

        retVal=$?
        if [ $retVal != 0 ]; then
                echo " "
                echo "Flashing Error! Please re-run this script..."
                echo " "
                exit $retVal
        fi
else
        echo "Exiting..."
        echo " "
        exit 1
fi
