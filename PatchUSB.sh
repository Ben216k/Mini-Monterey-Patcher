#!/bin/bash

#  PatchUSB.sh
#  Mini Monterey
#
#  Created by Ben Sova on 6/9/21.
#
#  Credit to some of the great people that
#  are working to make macOS run smoothly
#  on unsupported Macs
#

## MARK: Fun stuff

[ $UID = 0 ] || exec sudo "$0" "$@"

error() {
    echo
    echo "$1" 1>&2
    exit 1
}

echo "Welcome to Mini Monterey's PatchUSB.sh!"
echo 'This script is in alpha stages right now, but more will come in the future.'
echo

# MARK: Detect USB and Payloads

echo 'Detecting Installer USB at /Volumes/Install macOS 12 Beta...'

if [[ -d '/Volumes/Install macOS 12 Beta/Install macOS 12 Beta.app' ]]; then
    INSTALLER='/Volumes/Install macOS 12 Beta'
    APPPATH="$INSTALLER/Install macOS 12 Beta.app"
else
    echo 'Installer USB was not detected.'
    echo 'Please be sure to not rename the USB'
    error 'Error 2x1: Installer Not Found'
fi

echo 'Installer USB Detected!'

echo

echo 'Detecting patches at script directory...'

PATCHES="$(dirname $0)"

if [[ ! -d "$PATCHES/InstallerPatches" ]]; then
    echo 'The patches for Mini Monterey could not be found.'
    echo "Theres really no logical explaination for this..."
    error "Error 2x1 The Patches Weren't Found"
fi

echo


# MARK: Verifying thing

if [[ ! "$1" == "--no-setvars" ]]; then

    MOUNTEDPARTITION=`mount | fgrep "$INSTALLER" | awk '{print $1}'`
    if [[ -z "$MOUNTEDPARTITION" ]]; then
        echo Failed to find the partition that
        echo "$INSTALLER"
        echo is mounted from.
        exit 1
    fi

    DEVICE=`echo -n $MOUNTEDPARTITION | sed -e 's/s[0-9]*$//'`
    PARTITION=`echo -n $MOUNTEDPARTITION | sed -e 's/^.*disk[0-9]*s//'`
    echo "$INSTALLER found on device $MOUNTEDPARTITION"

    if [[ "x$PARTITION" = "x1" ]]; then
        error 'This drive is not formatted with a GUID Partition Map'
    fi

fi

# MARK: Patch Boot PLIST

echo 'Patching Boot PLIST...'

# Apparently running CP then CAT is better than MV
# but I guess there is some sort of permissions trick
# that makes this better.

if [[ ! -e "$INSTALLER/Library/Preferences/SystemConfiguration/com.apple.Boot.plist.stock" ]]; then
    cp "$INSTALLER/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" "$INSTALLER/Library/Preferences/SystemConfiguration/com.apple.Boot.plist.stock" || error 'Error 2x2 Unable backup boot plist.'
fi

cat "$PATCHES/InstallerPatches/com.apple.Boot.plist" > "$INSTALLER/Library/Preferences/SystemConfiguration/com.apple.Boot.plist" || error 'Error 2x2 Unable replace boot plist.'

echo 'Patched Boot PLIST'
echo

# MARK: Adding Kexts to Installer USB

echo 'Add Patches.'

cp -rf "$PATCHES/KextPatches" "$INSTALLER" || error 'Error 2x2 Unable to add patched kexts to installer.'
cp -rf "$PATCHES/SystemPatches" "$INSTALLER" || error 'Error 2x2 Unable to add system patches to installer.'

echo 'Added Patches.'
echo

# MARK: Add BarryKN Hax Tool

echo 'Adding Installer Override...'

mkdir "$INSTALLER/InstallerHax" || error 'Error 2x2 Somehow unable to make BarryKN Hax folder.'
cp -rf "$PATCHES/InstallerHax/Hax3-BarryKN/HaxDoNotSeal.dylib" "$INSTALLER/InstallerHax/NoSeal.dylib" || error 'Error 2x2 Unable to add BarryKN Hax to the USB.'
cp -rf "$PATCHES/InstallerHax/Hax3-BarryKN/HaxSeal.dylib" "$INSTALLER/InstallerHax/YesSeal.dylib" || error 'Error 2x2 Unable to add BarryKN Hax to the USB.'
cp -rf "$PATCHES/InstallerHax/Hax3-BarryKN/HaxSealNoAPFSROMCheck.dylib" "$INSTALLER/InstallerHax/YesSealNoAPFS.dylib" || error 'Error 2x2 Unable to add BarryKN Hax to the USB.'
cp -rf "$PATCHES/InstallerHax/Hax3-BarryKN/HaxDoNotSealNoAPFSROMCheck.dylib" "$INSTALLER/InstallerHax/NoSealNoAPFS.dylib" || error 'Error 2x2 Unable to add BarryKN Hax to the USB.'

echo 'Added BarryKN Hax.'
echo

# MARK: Add Backup Scripts

#echo "PatchKexts.sh cannot be added yet."
# echo 'Adding Backup Scripts...'
echo 'Adding PatchSystem.sh...'
cp -f "$PATCHES/Scripts/PatchKexts.sh" "$INSTALLER" || error 'Error 2x2 Unable to add PatchSystem.sh'
# echo 'Adding extra commands...'
# cp -a $PATCHES/ArchiveBin "$INSTALLER/ArchiveBin" || error 'Error 2x2 Unable to add extra commands.'
#echo 'Added extra commands...'
# echo 'Added Backup Scripts'
echo

# MARK: Setup Trampoline App

echo 'Setting up trampoline app...'
TEMPAPP="$INSTALLER/tmp.app"
mv -f "$APPPATH" "$TEMPAPP"
cp -r "$PATCHES/InstallerPatches/trampoline.app" "$APPPATH"
mv -f "$TEMPAPP" "$APPPATH/Contents/MacOS/InstallAssistant.app"
cp "$APPPATH/Contents/MacOS/InstallAssistant" "$APPPATH/Contents/MacOS/InstallAssistant_plain"
cp "$APPPATH/Contents/MacOS/InstallAssistant" "$APPPATH/Contents/MacOS/InstallAssistant_springboard"
pushd "$APPPATH/Contents" > /dev/null
for item in `cd MacOS/InstallAssistant.app/Contents;ls -1 | fgrep -v MacOS`
do
    ln -s MacOS/InstallAssistant.app/Contents/$item .
done
popd > /dev/null
touch "$APPPATH"
echo 'Setup trampoline app.'
echo

# MARK: Confirm Permissions

echo 'Confirming script permissions...'

chmod -R u+x "$INSTALLER"/InstallerHax/*.dylib

echo 'Confirmed permissions...'

echo

# MARK: The Extra Things


echo 'Theming the installer icon...'

cp -rf $PATCHES/Images/InstallIcon.icns "$INSTALLER"/.VolumeIcon.icns

echo 'Themed (or at least tried to) the installer icon'

echo 'Replacing Boot.efi'

cp -rf "$PATCHES/InstallerPatches/boot.efi" "$INSTALLER/System/Library/CoreServices/boot.efi"

echo 'Replaced Boot.efi'

echo

# MARK: Sync and Finish

echo 'Finishing drive processes...'

sync

echo

echo 'Finished Patching USB!'
echo 'Now installing SetVars tool...'

# MARK: - Install SetVars

# This code is from the micropatcher.

if [[ ! "$1" == "--no-setvars" ]]; then
    
    checkDirAccess() {
        # List the two directories, but direct both stdout and stderr to
        # /dev/null. We are only interested in the return code.
        ls "$INSTALLER" . &> /dev/null
    }

    # Make sure there isn't already an "EFI" volume mounted.
    if [ -d "/Volumes/EFI" ]
    then
        echo 'An "EFI" volume is already mounted. Please unmount it then try again.'
        echo "If you don't know what this means, then restart your Mac and try again."
        echo
        error 'EFI Volume already mounted.'
    fi

    cd $PATCHES

    # Check again in case we changed directory after the first check
    if [ ! -d EFISetvars ]
    then
        error '"EFISetvars" folder was not founnd'
    fi

    # Check to make sure we can access both our own directory and the root
    # directory of the USB stick.
    if [ `uname -r | sed -e 's@\..*@@'` -ge 19 ]
    then
        echo 'Checking read access to necessary directories...'
        if ! checkDirAccess
        then
            echo 'Access check failed.'
            tccutil reset All com.apple.Terminal
            echo 'Retrying access check...'
            if ! checkDirAccess
            then
                echo
                error 'Error 2x9 Terminal does not have the correct permissions, please give it Full Disk Access.'
            else
                echo 'Access check succeeded on second attempt.'
                echo
            fi
        else
            echo 'Access check succeeded.'
            echo
        fi
    fi

    diskutil mount ${DEVICE}s1
    if [[ ! -d "/Volumes/EFI" ]]; then
        echo "Partition 1 of the USB stick does not appear to be an EFI partition, or"
        echo "mounting of the partition somehow failed."
        error 'Error 2x2 Could not find (or mount?) the EFI partition of this device.'
    fi

    echo 'The patcher is unfinished, so just leaving SIP on'
    SIPARV="YES"

    # Now do the actual installation
    echo "Installing setvars EFI utility."
    rm -rf /Volumes/EFI/EFI
    if [ "x$VERBOSEBOOT" = "xYES" ]
    then
        if [ "x$SIPARV" = "xYES" ]
        then
            echo 'Verbose boot enabled, SIP/ARV enabled'
    #         cp -r EFISetvars/EFI-enablesiparv-vb /Volumes/EFI/EFI
        else
    #         echo 'Verbose boot enabled, SIP/ARV disabled'
            cp -r EFISetvars/EFI-verboseboot /Volumes/EFI/EFI
        fi
    elif [ "x$SIPARV" = "xYES" ]
    then
    #     echo 'Verbose boot disabled, SIP/ARV enabled'
        cp -r EFISetvars/EFI-enablesiparv /Volumes/EFI/EFI
    else
    #     echo 'Verbose boot disabled, SIP/ARV disabled'
        cp -r EFISetvars/EFI /Volumes/EFI/EFI
    fi

    echo 'Adding icons...'
    cp -rf $PATCHES/Images/EFIIcon.icns /Volumes/EFI/.VolumeIcon.icns

    echo "Unmounting EFI volume if we can..."
    umount /Volumes/EFI || diskutil unmount /Volumes/EFI

fi

echo
echo 'Mini Monterey PatchUSB.sh has finished. Refer to the README for instruction on how to continue.'
