#!/bin/bash

INSTANCE_NAME=`cat /etc/chef/client.rb | grep node_name | cut -d" " -f2 | cut -d"\"" -f2`
##alternative method with EC2 
##  choose INSTANCE_NAME instead to stay compatible with non EC2 environements
##   INSTANCE_NAME=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
knife node delete $INSTANCE_NAME -c /etc/chef/client.rb -y
##TODO: does not work without giving additional rights
#knife client delete $INSTANCE_NAME -c /etc/chef/client.rb
/home/ubuntu/set-instance-tag.sh DECOMMISSIONED
shutdown -P now

