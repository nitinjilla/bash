#!/bin/bash

# Author: Nitin Ganesh Jilla

# To create/extend VG (xfs) in bash

function manual(){
cat << EOF

Usage: mkmnt -d <dev-id> -s <size> -v <volume-group> -l <logical-volume> -m <mount-point>

    -d      Disk device                     (for e.g. /dev/sdb)
    -s      Size in MB, GB, TB              (for e.g. 2g, 50m)
    -v      Name of the volume group
    -l      Name of the logical volume
    -m      Absolute path of the mount point (for e.g. /test, /opt/test/tested)

Example:
To create a VG
mkmnt -d /dev/sdb -v testVG

To create an LV named testLV of size 1 GB in testVG and mount it on /test
mkmnt -d /dev/sdb -s 1G -v testVG -l testLV -m /test

EOF
}

function createLV(){

local $size=$1
local $volumegroup=$2
local $logicalvolume=$3
local $mountpoint=$4

read -p "Do you want to create a new logical volume? [yes/no] " makelv

if [[ $makelv -eq "yes" ]]; then
    if [[ -z $size ]] || [[ -z $logicalvolume ]] || [[ -z $mountpoint ]]; then
        echo "Missing size, LV or mount-point definition. Exiting..."
        exit 1
    else
        echo "LOG: Creating an LV"
        lvcreate -L+$size -n $logicalvolume $volumegroup
        mkfs.xfs /dev/$volumegroup/$logicalvolume
        mkdir -p $mountpoint
        echo "/dev/$volumegroup/$logicalvolume   $mountpoint                xfs defaults            0 0" >> /etc/fstab
        mount -a

        df -h $mountpoint
    fi

else
        exit 0
fi
}

#  "LOG: Start"

while getopts “v:d:slmh” OPTION
do
    case $OPTION in
        s)
            size=$OPTARG
            ;;
        v)
            volumegroup=$OPTARG
            ;;
        l)
            logicalvolume=$OPTARG
            ;;
        m)
            mountpoint=$OPTARG
            ;;
        d)
            disk=$OPTARG
            ;;
        h)
            manual
            exit 1
            ;;
    esac
done


if [[ -z $volumegroup ]] || [[ -z $disk ]]; then
    echo "Missing VG or disk definition. Exiting..."
    echo "Try 'mkmnt -h' for more information."
    exit 1
else
    pvcreate $disk
    #If VG exists, extend
    if vgs | awk '{print $1}' | grep -w $volumegroup && echo "VG $volumegroup found!"; then
        vgextend $volumegroup $disk
        createLV $size $volumegroup $logicalvolume $mountpoint
    else
    #If VG does not exist, create a new VG and LV
        echo "VG $volumegroup not found. Creating a new one!"
        vgcreate $logicalvolume $disk
        createLV $size $volumegroup $logicalvolume $mountpoint
        fi
fi
