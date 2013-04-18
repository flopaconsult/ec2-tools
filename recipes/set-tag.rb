#
# Cookbook Name:: ec2-tools
# Recipe:: set-tag
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "ec2-tools::default"


###
# 
###
if node[:environment][:name].length > 0
  iname = node[:environment][:name] + "-" + node[:ec2tag][:name]
else
  iname = node[:ec2tag][:name]
end
if iname.length ==0
  iname="NONAME"
end

template "/home/ubuntu/set-instance-tag.sh"  do
  source "set-instance-tag.sh"
  mode 0755
  owner "root"
  group "ubuntu"
  variables(
    :instancename => iname
  )
end

execute "set tag"  do
  user "ubuntu"
  command "/home/ubuntu/set-instance-tag.sh"
  action :run
end

