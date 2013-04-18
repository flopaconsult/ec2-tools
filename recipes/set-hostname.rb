#
# Cookbook Name:: ec2-tools
# Recipe:: set-hostname
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


## This recipe fixes hostname problems with the current Canonical Ubuntu 10.04 AMI.
##  A stopped EBS instance sometimes does not have a valid hostname. This causes all kind of problem with Chef. For example knife ssh tries to connect to the old IP address of the EC2 instance...
##  An EC2 instance with a wrong hostname needs to run chef-client 2x times! The chef-client seems to update the chef server data at the beginning of


#include_recipe "ec2-tools::default"
#
#execute "get hostname"  do
#  command "ec2-metadata --local-hostname | cut -d\" \" -f2 | cut -d\".\" -f1 > /home/ubuntu/hostname"
#  action :run
#end


#TODO: FIX (2011/7/8): remove this resource when no old chef-instances whith the former permission exist!
e = file "/home/ubuntu/hostname" do
  owner "ubuntu"  
  group "root"  
  mode "0644"  
  action :nothing
  only_if "test -f /home/ubuntu/hostname"
end
e.run_action(:touch)


e = execute "get hostname"  do
  user "ubuntu"
  command "curl -s http://169.254.169.254/latest/meta-data/local-hostname | cut -d\".\" -f1 > /home/ubuntu/hostname"
  action :nothing
end

e.run_action(:run)

ereload = ruby_block "reload ohai" do
  block do
    ohai = Ohai::System.new
    ohai.all_plugins
    node.automatic_attrs = ohai.data
    node.save
    Chef::Log.info("Updated chef server config with new ohai system info.")
  end
  action :nothing
end

erestart = execute "restart hostname service"  do
  command "/etc/init.d/hostname restart"
  action :nothing
  notifies :create, "ruby_block[reload ohai]", :immediately
end

e = execute "set new hostname"  do
  command "cp /etc/hostname /home/ubuntu/hostname.orig.`date +\"%Y-%m-%d_%T\"` && cp /home/ubuntu/hostname /etc/hostname"
  action :nothing
  not_if "cat /etc/hostname | grep `cat /home/ubuntu/hostname`"
  notifies :run, "execute[restart hostname service]", :immediately
end

checkhost = %x[cat /etc/hostname | grep `cat /home/ubuntu/hostname`]
e.run_action(:run)

##During Chef compile time notifications seem not to be available.
#  So we are calling the resources manually.
if checkhost.length == 0
  erestart.run_action(:run)
  ereload.run_action(:create)
end

