#!/bin/bash

keydir=/home/ubuntu
export EC2_PRIVATE_KEY=`ls $keydir/pk-*.pem`
export EC2_CERT=`ls $keydir/cert-*.pem`
export INSTANCE_ID=`ec2-metadata -i | cut -d" " -f2`
###TODO: check
###  ec2-metadata seems not to be reliable! It suddenly started returning "not available" while curl is still working!
export INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
if [ "$1" == "" ]; then
ec2-create-tags $INSTANCE_ID --tag Name=<%= @instancename %>
else
ec2-create-tags $INSTANCE_ID --tag Name=<%= @instancename %>-$1
fi

<% if node[:environment][:name].length > 0 -%>
ec2-create-tags $INSTANCE_ID --tag Environment=<%= node[:environment][:name] %>
<% end -%>

<% if node[:ec2tag][:name].length > 0 -%>
ec2-create-tags $INSTANCE_ID --tag Role=<%= node[:ec2tag][:name] %>
<% end -%>

