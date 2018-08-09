#! /bin/sh
root_folder="utapass"
espresso_folder=""

function print() {
    echo "============================================================"
    echo "${1:-No Message}"
    echo "============================================================"
}

function clone_utapass_android() {
    print "Cloning Souce Code - Utapass Android"
    git clone https://github.com/KKBOX/utapass.git

    # error handling - when cloning fail
    [ $? -ne 0 ] && exit 1

    # error handling - when folder 'utapass' doesn't exist for unknown reason
    [ ! -d "utapass" ] && echo "Folder 'utapass' doesn't exist (clone failed?)" && exit 1

    echo "" && return 0
}

function clean_folder() {
    local folder="utapass/app/src/androidTest/java/com/kddi/android/UtaPass"
    print "Cleaning Folder - $folder "
    [ -d "$folder" ] && rm -rf ${folder}/*

    echo "Done"
    echo "" && return 0
}

function clone_utapass_espresso() {
    print "Cloning Souce Code (submodule) - Utapass Espresso"

    local folder="app/src/androidTest/java/com/kddi/android/UtaPass/sqa_espresso"
    cd "utapass"
    git submodule add "https://github.com/PaservanYu/utapass-espresso.git" "$folder"

    # error handling - when cloning fail
    [ $? -ne 0 ] && exit 1

    # error handling - when folder 'utapass' doesn't exist for unknown reason
    [ ! -d "$folder" ] && echo "Folder '$folder' doesn't exist (clone failed?)" && exit 1

    echo "" && return 0
}

clone_utapass_android
clean_folder
clone_utapass_espresso
