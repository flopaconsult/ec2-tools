#
# Cookbook Name:: ec2-tools
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


###
# 
###
cookbook_file "/etc/apt/sources.list.d/backports.list"  do
  source "backports.list"
  mode 0644
  owner "root"
  group "root"
  notifies :run, "execute[update]", :immediately
end
execute "update"  do
  command "sudo apt-get update"
  action :nothing
end
package "ec2-api-tools"  do
  action :install
end


###
# 
###
cookbook_file "/usr/bin/ec2-metadata"  do
  source "ec2-metadata"
  mode 0755
  owner "root"
  group "root"
end

cookbook_file "/home/ubuntu/pk-tag_access.pem"  do
  source node[:ec2tag][:pk_file]
  mode 0740
  owner "ubuntu"
  group "root"
end
cookbook_file "/home/ubuntu/cert-tag_access.pem"  do
  source node[:ec2tag][:cert_file]
  mode 0740
  owner "ubuntu"
  group "root"
end
cookbook_file "/home/ubuntu/get-instance-tag.sh"  do
  source "get-instance-tag.sh"
  mode 0755
  owner "root"
  group "ubuntu"
end
cookbook_file "/home/ubuntu/set-bash-profile.sh"  do
  source "set-bash-profile.sh"
  mode 0755
  owner "root"
  group "ubuntu"
end
cookbook_file "/home/ubuntu/decommission.sh"  do
  source "decommission.sh"
  mode 0750
  owner "root"
  group "root"
end

#TODO: FIX (2011/7/8): remove this two resources when no old chef-instances whith the former permission exist!
file "/home/ubuntu/hostname" do
  owner "ubuntu"  
  group "root"  
  mode "0644"  
  action :touch
  only_if "test -f /home/ubuntu/hostname"
end
file "/home/ubuntu/instance-tag.txt" do
  owner "ubuntu"  
  group "root"  
  mode "0644"  
  action :touch
  only_if "test -f /home/ubuntu/instance-tag.txt"
end


execute "get tag"  do
  user "ubuntu"
  command "/home/ubuntu/get-instance-tag.sh"
  action :run
end
execute "set prompt"  do
  user "ubuntu"
  command "/home/ubuntu/set-bash-profile.sh"
  action :run
end

