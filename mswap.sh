#!/bin/bash

#Author: Nitin Jilla

#About: Helps manage swap partition.

function newswap(){

        local VG=$1
        local LV=$2
        local size=$3

        echo "Current swap memory stats:"
        free -h | awk 'NR==3{print $2}'
        sleep 5
        lvcreate -L+$size -n $LV $VG
        mkswap /dev/$VG/$LV
        swapon /dev/$VG/$LV
        echo '/dev/$VG/$LV       swap                    swap    defaults        0 0' >> /etc/fstab
        mount -a

}

function extendswap(){

        local VG=$1
        local LV=$2
        local size=$3

        swapoff -v /dev/$VG/$LV
        lvextend -L+$size /dev/$VG/$LV
        mkswap /dev/$VG/$LV
        swapon -v /dev/$VG/$LV

}


function manual(){
cat << EOF


        Usage:
        To create a new swap partition
        mswap -v <volume-group> -l <logical-volume> -s <size> -c

        To extend an existing swap partition
        mswap -v <volume-group> -l <logical-volume> -s <size> -x

        Arguments:
        -c      Creates a new swap partition (Does not take arguments)
        -x      Extends previously created swap partition (Does not take arguments)
        -s      Size in MB, GB              (for e.g. 2g, 50m)
        -v      Name of the volume group
        -l      Name of the logical volume

EOF

}


while getopts “cxhl:v:s:” OPTION
do
     case $OPTION in
         l)
             LV=$OPTARG
             ;;
         v)
             VG=$OPTARG
             ;;
         s)
             size=$OPTARG
             ;;
         c)
             newswap "$VG" "$LV" "$size"
             ;;
         x)
             extendswap "$VG" "$LV" "$size"
             ;;
         h|*)
             manual
             exit 1
             ;;
     esac
done


if [[ -z $size ]] || [[ -z $VG ]] || [[ -z $LV ]]; then
        echo "Missing some values. Exiting..."
        manual
        exit 1
fi
