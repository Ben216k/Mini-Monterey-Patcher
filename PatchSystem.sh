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

if [[ -z "$1" ]] || [[ "$1" == "--detect" ]]; then
    echo "Set to detect patches, restarting PatchSystem with NeededPatches..."
    "$(dirname "$0")/Scripts/NeededPatches.sh" --rerun $2
    exit $?
elif echo "$1" | grep '/Volumes/'; then
    echo "Set to detect patches, restarting PatchSystem with NeededPatches..."
    "$(dirname "$0")/Scripts/NeededPatches.sh" --rerun $1
    exit $?
fi

# MARK: Functions for Later

# Error out better for interfacing with the patcher.
error() {
    echo
    echo "$1" 1>&2
    exit 1
}

# Check for errors with the previous command. 
# Cleaner for non-inline uses.
errorCheck() {
    if [[ $? -ne 0 ]]; then
        error "$1"
    fi
}

# In the current directory, check for kexts which have been renamed from
# *.kext to *.kext.original, then remove the new versions and rename the
# old versions back into place.
restoreOriginals() {
    if [ -n "`ls -1d *.original`" ]
    then
        for x in *.original
        do
            BASENAME=`echo $x|sed -e 's@.original@@'`
            echo 'Unpatching' $BASENAME
            rm -rf "$BASENAME"
            mv "$x" "$BASENAME"
        done
    fi
}

# Fix permissions on the specified kexts.
fixPerms() {
    chown -R 0:0 "$@"
    chmod -R 755 "$@"
}

backupIfNeeded() {
    if [[ -d "$1".original ]]; then
        rm -rf "$1"
    else
        mv "$1" "$1".original
    fi
}

deleteIfNeeded() {
    if [[ -d "$1" ]]; then
        rm -rf "$1" || error "Failed to remove $1"
    else
        echo "$1 does not exist, so not deleting."
    fi
}

backupAndPatch() {
    if [[ "$3" == "YES" ]]; then
        echo "Patching from $2..."
        backupIfNeeded "$2"
        unzip -q "$LPATCHES/KextPatches/$1"
        errorCheck "Failed to patch $2."
        echo "Correcting permissions for $2..."
        fixPerms "$2"
        errorCheck "Failed to correct permissioms for $2."
    fi
}

justPatch() {
    if [[ "$3" == "YES" ]]; then
        echo "Patching from $2..."
        deleteIfNeeded "$2"
        unzip -q "$LPATCHES/KextPatches/$1"
        errorCheck "Failed to patch $2."
        echo "Correcting permissions for $2..."
        fixPerms "$2"
        errorCheck "Failed to correct permissioms for $2."
    fi
}

# Rootify script
[ $UID = 0 ] || exec sudo "$0" "$@"

echo "Welcome to Mini Monterey's PatchSystem.sh!"
echo 'Note: This script is still in alpha stages.'
echo

# MARK: Check Environment and Patch Kexts Location

echo "Checking environment..."
LPATCHES="/Volumes/Image Volume"
if [[ -d "$LPATCHES" ]]; then
    echo "[INFO] We're in a recovery environment."
    RECOVERY="YES"
else
    echo "[INFO] We're booted into full macOS."
    RECOVERY="NO"
    if [[ -d "$(dirname $0)/KextPatches" ]]; then
        echo '[INFO] Using dirname source.'
        LPATCHES="$(dirname $0)"
    elif [[ -d "/Volumes/Install macOS 12 Beta/KextPatches" ]]; then
        echo '[INFO] Using Install macOS 12 Beta source.'
        LPATCHES="/Volumes/Install macOS 12 Beta"
    elif [[ -d "/Volumes/Install macOS Monterey Beta/KextPatches" ]]; then
        echo '[INFO] Using Install macOS Monterey Beta source.'
        LPATCHES="/Volumes/Install macOS Monterey Beta"
    elif [[ -d "/Volumes/Install macOS Monterey/KextPatches" ]]; then
        echo '[INFO] Using Install macOS Monterey source.'
        LPATCHES="/Volumes/Install macOS Monterey"
    elif [[ -d "/usr/local/lib/Mini-Monterey-Patcher/KextPatches" ]]; then
        echo '[INFO] Using usr lib source.'
        LPATCHES="/usr/local/lib/Mini-Monterey-Patcher"
    fi
fi

echo
echo "Confirming patch location..."

if [[ ! -d "$LPATCHES" ]]; then
    echo "After checking every normal place, the patches were not found"
    echo "Please plug in a patched macOS installer USB, or install the"
    echo "Patched Sur post-install app to your Mac."
    error "Error 3x1: The patches for PatchKexts.sh were not detected."
fi

echo "[INFO] Patch Location: $LPATCHES"

echo "Checking csr-active-config..."
CSRCONFIG=`nvram csr-active-config`
if [[ ! "$CSRCONFIG" == "csr-active-config	%7f%08%00%00" ]]; then
    if [[ $RECOVERY == "YES" ]]; then
        echo "csr-active-config not setup correctly, correcting..."
        csrutil disable || error "[ERROR] SIP is on, which prevents the patcher from patching the kexts. Boot into the purple EFI Boot on the installer USB to fix this. Patched Sur attempted to fix this, but failed."
        csrutil authenticated-root disable || error "[ERROR] SIP is on, which prevents the patcher from patching the kexts. Boot into the purple EFI Boot on the installer USB to fix this. Patched Sur attempted to fix this, but failed."
    else
        error "[ERROR] SIP is on, which prevents the patcher from patching the kexts. Boot into the purple EFI Boot on the installer USB to fix this."
    fi
fi

echo
echo "Checking Arguments..."

while [[ $1 == -* ]]; do
    case $1 in
        -u)
            echo '[CONFIG] Unpatching system.'
            echo 'Note: This may not fully (or correctly) remove all patches.'
            ;;
        --wifi-that-will-fail-and-i-have-no-idea-why-you-are-trying-to-use-this)
            echo '[CONFIG] Will patch IO80211Family.kext for WiFi.'
            WIFIPATCH="MOJAVE-PLUS"
            ;;
        --hd4000)
            echo '[CONFIG] Will patch AppleIntelHD4000.kext for Graphics Acceleration'
            HD4000="YES"
            ;;
        --bootPlist)
            echo "[CONFIG] Will patch com.apple.Boot.plist for NVRAM Resets"
            BOOTPLIST="YES"
            ;;
        --noRebuild)
            echo "[CONFIG] Will patch without rebuilding the kernel collection."
            NOREBUILD="YES"
            ;;
        *)
            echo "Unknown option, ignoring. $1"
            ;;
    esac
    shift
done

echo
echo 'Checking patch to volume...'

if [[ $RECOVERY == "YES" ]] && [[ ! -d "$1" ]]; then
    echo "[CONFIG] Looking for $1"
    echo 'Make sure to run the script with path/to/PatchSystem.sh "NAME-OF-BIG-SUR-VOLUME"'
    error "No volume was specificed on the command line or the volume selected is invalid."
elif [[ -d "$1" ]]; then
    echo "[CONFIG] Patching to $1"
    VOLUME="$1"
else
    echo "[CONFIG] Patching to /System/Volumes/Update/mnt1 (booted system snapshot)"
    VOLUME="/"
fi

if [[ ! -d "$VOLUME" ]]
then
    echo 'Make sure to run the script with path/to/PatchSystem.sh /Volumes/"NAME-OF-BIG-SUR-VOLUME" (keep the quotes)'
    error "No volume was specificed on the command line or the volume selected is invalid."
fi

echo
echo "Verifying volume..."

if [[ ! -d "$VOLUME/System/Library/Extensions" ]]; then
    error "This volume is not the macOS system volume, but it could be a data volume or a different OS."
fi

if [[ ! "$1" == "PROTONS" ]]; then
    
    SVPL="$VOLUME"/System/Library/CoreServices/SystemVersion.plist
    SVPL_VER=`fgrep '<string>10' "$SVPL" | sed -e 's@^.*<string>10@10@' -e 's@</string>@@' | uniq -d`
    SVPL_BUILD=`grep '<string>[0-9][0-9][A-Z]' "$SVPL" | sed -e 's@^.*<string>@@' -e 's@</string>@@'`

    if echo $SVPL_BUILD | grep -q '^21'
    then
        echo -n "[INFO] Volume has Big Sur build" $SVPL_BUILD
    else
        if [ -z "$SVPL_VER" ]
        then
            error "Unknown macOS version on volume."
        else
            error "macOS $SVPL_VER build $SVPL_BUILD detected. This patcher only works on Big Sur."
        fi
        exit 1
    fi

fi

# MARK: Preparing for Patching

echo

echo 'Unmounting underlying volume just incase.'
umount "/System/Volumes/Update/mnt1" || diskutil unmount force "/System/Volumes/Update/mnt1"

echo "Remounting Volume..."

if [[ "$VOLUME" = "/" ]]; then
    DEVICE=`df "$VOLUME" | tail -1 | sed -e 's@ .*@@'`
    POPSLICE=`echo $DEVICE | sed -E 's@s[0-9]+$@@'`
    VOLUME="/System/Volumes/Update/mnt1"

    echo "[INFO] Remounting snapshot with IDs $DEVICE and $POPSLICE"

    mount -o nobrowse -t apfs "$POPSLICE" "$VOLUME"
    errorCheck "Failed to remount snapshot as read/write. This is probably because your Mac is optimizing. Wait 5 minutes, reboot, wait 5 minutes again then try again."
else
    mount -uw "$VOLUME"
    errorCheck "Failed to remount volume as read/write."
fi

if [[ ! "$PATCHMODE" == "UNINSTALL" ]]; then
    # MARK: Backing Up System

    echo "Checking for backup..."
    pushd "$VOLUME/System/Library/KernelCollections" > /dev/null
    BACKUP_FILE_BASE="KernelCollections-$SVPL_BUILD.tar"
    BACKUP_FILE="$BACKUP_FILE_BASE".lz4
    
    if [[ -e "$BACKUP_FILE" ]]; then
        echo "Backup already there, so not overwriting."
    else
        echo "Backup not found. Performing backup now. This may take a few minutes."
        echo "Backing up original KernelCollections to:"
        echo `pwd`/"$BACKUP_FILE"
        tar cv *.kc | "$VOLUME/usr/bin/compression_tool" -encode -a lz4 > "$BACKUP_FILE"

        if [ $? -ne 0 ]
        then
            echo "tar or compression_tool failed. See above output for more information."

            echo "Attempting to remove incomplete backup..."
            rm -f "$BACKUP_FILE" || error "Failed to backup kernel collection and failed to delete the incomplete backup."
            
            error "Failed to backup kernel collection. Check the logs for more info."
        fi
    fi
    
    popd > /dev/null

    # MARK: Patching System

    pushd "$VOLUME/System/Library/Extensions" > /dev/null

    echo "Beginning Kext Patching..."

    if [[ ! -z "$WIFIPATCH" ]]; then
        backupAndPatch IO80211FamilyLegacy.kext.zip IO80211FamilyLegacy.kext YES
    fi
    
    if [[ "$HD4000" == "YES" ]]; then
        justPatch AppleIntelFramebufferCapri.kext.zip AppleIntelFramebufferCapri.kext YES
        justPatch AppleIntelHD4000Graphics.kext.zip AppleIntelHD4000Graphics.kext YES
        justPatch AppleIntelHD4000GraphicsGLDriver.bundle.zip AppleIntelHD4000GraphicsGLDriver.bundle YES
        justPatch AppleIntelHD4000GraphicsMTLDriver.bundle.zip AppleIntelHD4000GraphicsMTLDriver.bundle YES
        justPatch AppleIntelHD4000GraphicsVADriver.bundle.zip AppleIntelHD4000GraphicsVADriver.bundle YES
        justPatch AppleIntelGraphicsShared.bundle.zip AppleIntelGraphicsShared.bundle YES
        justPatch AppleIntelIVBVA.bundle.zip AppleIntelIVBVA.bundle YES
    fi
    
    popd > /dev/null

    if [[ "$BOOTPLIST" == "YES" ]]; then
        if [[ "$RECOVERY" == "YES" ]]; then
            echo "Cannot patch boot plist from recovery due to limitations."
        else
            echo 'Patching com.apple.Boot.plist (System Volume)...'
            pushd "$VOLUME/Library/Preferences/SystemConfiguration" > /dev/null
            cp "$LPATCHES/SystemPatches/com.apple.Boot.plist" com.apple.Boot.plist || echo 'Failed to patch com.apple.Boot.plist, however this is not fatal, so the patcher will not exit.'
            fixPerms com.apple.Boot.plist || echo 'Failed to correct permissions for com.apple.Boot.plist, however this is not fatal, so the patcher will not exit.'
            popd > /dev/null
            pushd "$VOLUME/System/Library/CoreServices" > /dev/null
            echo 'Patching PlatformSupport.plist (System Volume)...'
            cp "$LPATCHES/SystemPatches/PlatformSupport.plist" PlatformSupport.plist || echo 'Failed to patch PlatformSupport.plist, however this is not fatal, so the patcher will not exit.'
            fixPerms "PlatformSupport.plist" || echo 'Failed to correct permissions PlatformSupport.plist, however this is not fatal, so the patcher will not exit.'
            popd > /dev/null

            echo 'Making sure the Premount volume is mounted for Boot.plist patches...'
            PREMOUNTID=`diskutil list | grep Preboot | head -n 1 | cut -c 71-`
            diskutil mount "$PREMOUNTID"
            if [[ "$VOLUME" == "/System/Volumes/Update/mnt1" ]]; then
                APFSID=`diskutil info / | grep "APFS Volume Group" | cut -c 31-`
            else
                APFSID=`diskutil info $VOLUME | grep "APFS Volume Group" | cut -c 31-`
            fi

            pushd "/System/Volumes/Preboot/$APFSID/Library/Preferences/SystemConfiguration" > /dev/null
            echo 'Patching com.apple.Boot.plist (Preboot Volume)...'
            cp -X "$LPATCHES/SystemPatches/com.apple.Boot.plist" com.apple.Boot.plist || echo 'Failed to patch com.apple.Boot.plist, however this is not fatal, so the patcher will not exit.'
            fixPerms com.apple.Boot.plist || echo 'Failed to correct permissions for com.apple.Boot.plist, however this is not fatal, so the patcher will not exit.'
            popd > /dev/null
            pushd "/System/Volumes/Preboot/$APFSID/Library/Preferences/SystemConfiguration" > /dev/null
            echo 'Patching PlatformSupport.plist (Preboot Volume)...'
            cp -X "$LPATCHES/SystemPatches/PlatformSupport.plist" PlatformSupport.plist || echo 'Failed to patch PlatformSupport.plist, however this is not fatal, so the patcher will not exit.'
            fixPerms "PlatformSupport.plist" || echo 'Failed to correct permissions PlatformSupport.plist, however this is not fatal, so the patcher will not exit.'
            popd > /dev/null
        fi
    fi

    # MARK: Rebuild Kernel Collection 

    if [[ ! $NOREBUILD == "YES" ]]; then
        echo 'Rebuilding boot collection...'
        chroot "$VOLUME" kmutil create -n boot \
            --kernel /System/Library/Kernels/kernel \
            --variant-suffix release --volume-root / \
            --boot-path /System/Library/KernelCollections/BootKernelExtensions.kc
        errorCheck 'Failed to rebuild kernel boot collection.'

        echo 'Rebuilding system collection...'
        chroot "$VOLUME" kmutil create -n sys \
            --kernel /System/Library/Kernels/kernel \
            --variant-suffix release --volume-root / \
            --system-path /System/Library/KernelCollections/SystemKernelExtensions.kc \
            --boot-path /System/Library/KernelCollections/BootKernelExtensions.kc
        errorCheck 'Failed to rebuild kernel system collection.'

        echo "Finished rebuilding!"
    fi
else
    # MARK: Unpatch Kexts

    pushd "$VOLUME/System/Library/KernelCollections" > /dev/null

    BACKUP_FILE_BASE="KernelCollections-$SVPL_BUILD.tar"
    BACKUP_FILE="$BACKUP_FILE_BASE".lz4

    if [ ! -e "$BACKUP_FILE" ]
    then
        error "Failed to find kernel collection backup at $(pwd)/$BACKUP_FILE"
    fi
    
    echo "Restoring KernelCollections backup from: $(pwd)/$BACKUP_FILE"
    rm -rf *.kc
    "$VOLUME/usr/bin/compression_tool" -decode < "$BACKUP_FILE" | tar xpv
    errorCheck 'Failed to unpatch the KernelCollection'
    rm -rf "$BACKUP_FILE"
    
    popd > /dev/null
    
    echo "Unpatching kexts"
    pushd "$VOLUME/System/Library/Extensions" > /dev/null
    restoreOriginals
    
    popd > /dev/null
fi

# MARK: Finish Up
if [[ ! $NOREBUILD == "YES" ]]; then
    echo 'Running kcditto...'
    "$VOLUME/usr/sbin/kcditto"
    errorCheck 'kcditto failed.'
fi

echo 'Reblessing volume...'
bless --folder "$VOLUME"/System/Library/CoreServices --bootefi --create-snapshot --setBoot
errorCheck bless


if [[ "$VOLUME" = "/System/Volumes/Update/mnt1" ]]; then
    echo "Unmounting underlying volume..."
    umount "$VOLUME" || diskutil unmount "$VOLUME"
fi

echo 'Patched System Successfully!'
echo 'Reboot to finish up and enjoy Monterey!'
