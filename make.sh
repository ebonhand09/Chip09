#!/bin/bash

if [ -z "$1" ]
then
  BUILD_NAME=chip09
else
  BUILD_NAME=$1
fi

if [ -z "$2" ]
then
  DISK_IMAGE=./disks/$BUILD_NAME.dsk
else
  DISK_IMAGE=./disks/$2.dsk
fi

if [ ! -e "$DISK_IMAGE" ]
then
  decb dskini $DISK_IMAGE
fi

if [ -e "./source/$BUILD_NAME.asm" ]
then
  echo "Building ./source/$BUILD_NAME.asm into ./bin/$BUILD_NAME.bin..."
  lwasm -b -9 ./source/$BUILD_NAME.asm --output=./bin/$BUILD_NAME.bin --list=./logs/$BUILD_NAME.txt
  echo "Putting ./bin/$BUILD_NAME.bin into $DISK_IMAGE,${BUILD_NAME^^}.BIN ..."
  decb copy -2 -r ./bin/$BUILD_NAME.bin $DISK_IMAGE,${BUILD_NAME^^}.BIN
else
  echo "Specified file not found..."
fi


