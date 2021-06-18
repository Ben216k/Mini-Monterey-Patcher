#!/bin/zsh

SCANFOR=$1

VOLUME="/Volumes/ReMonterey"

checkKext() {
    # echo "$1"
    if [[ -d /Volumes/ModTree/System/Library/Extensions/"$1"/Contents/MacOS/ ]]; then
        echo -n "\u001b[30;1mAt \u001b[34;1m$1 > \u001b[30;1m"
        if ! nm -U /Volumes/ModTree/System/Library/Extensions/"$1"/Contents/MacOS/* | grep "$SCANFOR"; then
            echo -ne "\033[2K"; printf "\r"
        fi
    fi
}

for kext in `ls -1 /Volumes/ModTree/System/Library/Extensions | grep -v ".bundle"`
    checkKext $kext

echo -n "\u001b[0m"
