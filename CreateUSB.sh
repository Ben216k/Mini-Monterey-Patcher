#!/bin/bash

#
#  PatchSystem.sh
#  Mini Monterey
#
#  Created by Ben Sova on 6/12/21
# 
#  Credit to some of the great people that
#  are working to make macOS run smoothly
#  on unsupported Macs
#

[ $UID = 0 ] || exec sudo "$0" "$@"

echo "Welcome to Mini Monterey's CreateUSB.sh!"

echo 'Checking Arguments...'

if [[ ! -d "$1" ]]; then
    echo 'No USB provided.'
    exit 1
fi

echo 'Checking where to download...'

CATALOGDATA="$(curl -s https://bensova.github.io/patched-monterey/Developer.json)"

MACVERS="$(echo "$CATALOGDATA" | grep "\"Version" | tail -n 1 | cut -c21- | cut -f1 -d"\"")"

MACURL="$(echo "$CATALOGDATA" | grep URL | tail -n 1 | cut -c17- | cut -f1 -d"\"")"

echo "Would you like to download macOS Monterey $MACVERS?"
echo "($MACURL)"
echo
read -p "(Y/N): " WOULDLIKE

if ! (echo $WOULDLIKE | grep -q Y || echo $WOULDLIKE | grep -q y); then
    echo "Canceling script."
    exit 1
fi

echo "Starting download..."
curl "$MACURL" -Lo ~/Downloads/"InstallAssistant $MACVERS.pkg" --progress-bar

echo "Done with download."
echo

echo "Extracting installer..."
installer -pkg ~/Downloads/"InstallAssistant $MACVERS.pkg" -target /

echo "Done extracting installer."
echo

echo "Creating installer..."

/Applications/"Install macOS 12 Beta"/Contents/Resources/createinstallmedia --volume "$1"

echo "Done creating installer. Now run PatchUSB.sh!"
