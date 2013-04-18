#
# Cookbook Name:: ec2-tools
# Recipe:: set-tag
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

currentCreationDate = node[:creation_date]

if (node[:creation_date].nil?) 
	node[:creation_date] = Time.now
	node.save
	
	currentCreationDate = node[:creation_date]
else
	currentCreationDate = Time.parse(node[:creation_date])
end

e = execute "install nokogiri_prereq"  do
  command "sudo apt-get -y install libxslt-dev libxml2-dev"
  action :nothing
end

e.run_action(:run) 

#if platform?("ubuntu", "debian")
#	e = package "libxslt-dev" do
#		action :nothing
#	end
#	e.run_action(:install)
#	e = package "libxml2-dev" do
#		action :nothing
#	end
#	e.run_action(:install)
#else
#	if platform?("redhat")
#		e = package "libxslt-devel" do
#			action :nothing
#		end
#		e.run_action(:install)
#		e = package "libxml2-devel" do
#			action :nothing
#		end
#		e.run_action(:install)
#	end
#end

e = gem_package "rdoc" do
	action :nothing
end
e.run_action(:install)

#e = execute "install excon"  do
#  command "sudo gem install excon -v0.6.1  --no-rdoc --no-ri"
#  action :nothing
#end
#
#e.run_action(:run) 

e = gem_package "excon" do
	version  "0.6.1"
	action :nothing
end
e.run_action(:install)

#e = execute "install prereq"  do
#  command "sudo gem install net-ssh net-ssh-multi highline --no-rdoc --no-ri"
#  action :nothing
#end
#
#e.run_action(:run) 

e = gem_package "net-ssh" do
	action :nothing
end
e.run_action(:install)
e = gem_package "net-ssh-multi" do
	action :nothing
end
e.run_action(:install)
e = gem_package "highline" do
	action :nothing
end
e.run_action(:install)

#e = execute "install fog"  do
#  command "sudo gem install fog -v0.7.2 --no-rdoc --no-ri"
#  action :nothing
#end
#
#e.run_action(:run) 

e = gem_package "fog" do
	version  "0.7.2"
	action :nothing
end
e.run_action(:install)

require 'rubygems'
Gem.clear_paths
require 'fog'

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

e = bash "get_instance_id" do
  code <<-EOH
  keydir=/home/ubuntu
  export EC2_PRIVATE_KEY=`ls $keydir/pk-*.pem`
  export EC2_CERT=`ls $keydir/cert-*.pem`
  export instance_id=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
  echo $instance_id > /tmp/instance_id
  export instance_name=`ec2-describe-tags --filter resource-id=$instance_id | grep Name | cut -f5`
  echo $instance_name > /tmp/instance_name
  EOH
end

e.run_action(:run) 

instance_id = IO.read('/tmp/instance_id').strip!
current_name = IO.read('/tmp/instance_name').strip!

#Chef::Log.info("[dist-repository] ========== Volume name is " + instance_id)

#Chef::Log.info("[ec2-tools] ========== current_name ")
#Chef::Log.info(current_name)

AWS = Fog::Compute.new( {
	:provider => 'AWS',
	:aws_access_key_id => 'AKIAJBQME4ZIHUI4KBBA',
	:aws_secret_access_key => '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'
})

roleQuery = ""
node[:roles].each do |nodeRole|
	unless nodeRole.eql?(node[:environment][:name])
		roleQuery += "roles: " + nodeRole + " OR " 
	end
end

if roleQuery.length > 0
	roleQuery = roleQuery[0, roleQuery.length - 4]
end

counter = 0;
if node.attribute["use_counter"].eql?("Y")
	search(:node, "(#{roleQuery}) AND app_environment:#{node[:app_environment]}") do |other_node|
		if instance_id.eql?(other_node[:ec2][:instance_id])
			next
		end
		unless other_node[:creation_date].nil?
			if currentCreationDate.nil?
					counter += 1
			else
				if Time.parse(other_node[:creation_date]) < currentCreationDate 
					counter += 1
				end
			end
		end
	end
end

if node[:original_name].nil?
	if counter > 0
		iname += "-" + counter.to_s()
	end
	node[:original_name] = iname
	node.save
else
	if node[:original_name].eql?(current_name)
		if node.attribute["use_counter"].eql?("Y") and counter > 0
#		if counter > 0
			iname += "-" + counter.to_s()
			node[:original_name] = iname
			node.save
		end
	else
		iname = current_name;
	end
end

server = AWS.servers.get(instance_id)

AWS.create_tags(instance_id, { "Name" => iname, "Environment" => node[:environment][:name], "Role" => node[:ec2tag][:name]})

puts server.id
puts server.tags
