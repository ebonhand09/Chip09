#!/bin/bash

if [ -z "$1" ]
then
  echo "No file specified..."
  exit
fi

if [ -z "$2" ]
then
  DISK_IMAGE=./disks/$1.dsk
else
  DISK_IMAGE=./disks/$2.dsk
fi

if [ ! -e "$DISK_IMAGE" ]
then
  decb dskini $DISK_IMAGE
fi

if [ -e "$1.asm" ]
then
  echo "Building ./source/$1.asm into ./bin/$1.bin..."
  lwasm -b -9 ./source/$1.asm --output=./bin/$1.bin --list=./logs/$1.txt
  echo "Putting ./bin/$1.bin into $DISK_IMAGE,${1^^}.BIN ..."
  decb copy -2 -r ./bin/$1.bin $DISK_IMAGE,${1^^}.BIN
else
  echo "Specified file not found..."
fi


