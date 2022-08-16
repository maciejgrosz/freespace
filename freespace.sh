#!/bin/bash

usage() {
  cat << EOF >&2
Usage: $0 [-r] [-t ###] file [file...]

-r: turn recursive mode on 
-t: pass new timeout value, default equal 48 hours
EOF
  exit 1
}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

function addSuffix() {
    DIR=$(dirname "$1");
    FILENAME=$(basename "$1");
    NEWNAME=$DIR/fc-$FILENAME
    mv "$1" "$NEWNAME"

}

function compressFile() {
    addSuffix "$1"
    gzip "$NEWNAME"
}

function changeZipName() {
    addSuffix "$1"
    touch "$NEWNAME"

}

function processZipFiles(){
    BASE=$(basename "$1")
    if [[ $BASE == "fc-"* ]]; then 
        if [ $(stat --format=%Y "$1") -le $(( $(date +%s) - $TIMEOUT*3600 )) ]; then
            rm "$1"
        fi
    else
        changeZipName "$1"
    fi    
}
function freespace() {
    for FILE in "$@"; do
        if [[ -d "$FILE" ]]; then
            continue
        fi
        file_type=$(file -b "$FILE" | awk '{print $1}')
        case $file_type in 
            *gzip|*Zip|*bzip2|compress*) processZipFiles "$FILE";; 
            *) compressFile "$FILE";
        esac
    done
}

function manageFreespace() {
    if [ "$RECURSIVE" == "-r" ]; then
        listOfFiles=$(find $@ -name "*")
    else
        listOfFiles=$(ls $@)
    fi
    for FILE in $listOfFiles; do
        if [[ -f "$FILE" ]]; then
            freespace "$FILE"
        fi
    done
}
# function manageFreespace(){
#     for FILE in "$@"; do
#         if [[ -f "$FILE" ]]; then
#             freespace "$FILE"
#         elif [[ -d "$FILE" ]]; then
#             pushd "$FILE" || exit
#             if [ "$RECURSIVE" == "-r" ]; then
#                 manageFreespace ./*
#             else
#                 freespace ./*
#             fi
#             popd
#         else
#             echo "Provided arguement is not a file or folder"
#         fi
#     done
# }

function main() {
    TIMEOUT=48
    local re='^[0-9]+$'
    while getopts ":t:r" opt; do
        case $opt in
        t) 
            if [[ "${OPTARG}" =~ $re ]]; then
                TIMEOUT=${OPTARG}
            else
                usage
            fi
            ;;
        r) RECURSIVE='-r';;
        \? ) usage
        esac
    done    
    shift $((OPTIND -1))

    manageFreespace "$@"
    local return_value=$?
    return $return_value

}

main "$@"