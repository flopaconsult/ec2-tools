#!/bin/bash

keydir=/home/ubuntu
export EC2_PRIVATE_KEY=`ls $keydir/pk-*.pem`
export EC2_CERT=`ls $keydir/cert-*.pem`
export INSTANCE_ID=`ec2-metadata -i | cut -d" " -f2`
###TODO: check
###  ec2-metadata seems not to be reliable! It suddenly started returning "not available" while curl is still working!
export INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
export INSTANCE_NAME=`ec2-describe-tags --filter resource-id=$INSTANCE_ID | grep Name | cut -f5`
echo $INSTANCE_NAME > /home/ubuntu/instance-tag.txt

