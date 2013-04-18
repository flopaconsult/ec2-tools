#!/bin/bash

INSTANCE_TAG=`cat /home/ubuntu/instance-tag.txt`
PROFILE="/home/ubuntu/.bash_profile"
PROFILE_TEMP="/home/ubuntu/.bash_profile.temp"
TAG_LINE2="#ec2-tag"
echo $TAG_LINE
echo $TAG_LINE2

if [ -f $PROFILE ]; then
  if [ `grep $TAG_LINE2 $PROFILE | wc -l` = "0" ]; then
    echo "PS1=\"\\u@$INSTANCE_TAG:\\w\\$ \"" $TAG_LINE2 >> $PROFILE
  else
    grep $TAG_LINE2 -v $PROFILE > $PROFILE_TEMP
    echo "PS1=\"\\u@$INSTANCE_TAG:\\w\\$ \"" $TAG_LINE2 >> $PROFILE_TEMP
    rm $PROFILE
    mv $PROFILE_TEMP $PROFILE
  fi
else
    echo "PS1=\"\\u@$INSTANCE_TAG:\\w\\$ \"" $TAG_LINE2 >> $PROFILE
fi


PROFILE="/home/ubuntu/.bashrc"
PROFILE_TEMP="/home/ubuntu/.bashrc.temp"

if [ -f $PROFILE ]; then
  if [ `grep $TAG_LINE2 $PROFILE | wc -l` = "0" ]; then
    echo "PS1=\"\\u@$INSTANCE_TAG:\\w\\$ \"" $TAG_LINE2 >> $PROFILE
  else
    grep $TAG_LINE2 -v $PROFILE > $PROFILE_TEMP
    echo "PS1=\"\\u@$INSTANCE_TAG:\\w\\$ \"" $TAG_LINE2 >> $PROFILE_TEMP
    rm $PROFILE
    mv $PROFILE_TEMP $PROFILE
  fi
else
    echo "PS1=\"\\u@$INSTANCE_TAG:\\w\\$ \"" $TAG_LINE2 >> $PROFILE
fi

