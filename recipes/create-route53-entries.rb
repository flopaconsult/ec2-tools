#!/usr/bin/env ruby

# Run with  ruby -rubygems create-route53-entries.rb i-0aeb7d6a swirltest.com CNAME us-east-1 
#	instance_id = "i-0aeb7d6a"

require 'fog'

unless defined? node
	instance_id = ARGV[0]
	domain_name = ARGV[1]
	type = ARGV[2]
	zone_name = ARGV[3]
else
	e = bash "get_instance_id" do
	  code <<-EOH
	  keydir=/home/ubuntu
	  export EC2_PRIVATE_KEY=`ls $keydir/pk-*.pem`
	  export EC2_CERT=`ls $keydir/cert-*.pem`
	  export instance_id=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
	  echo $instance_id > /tmp/instance_id
	  EOH
	end

	e.run_action(:run) 

	instance_id = IO.read('/tmp/instance_id').strip!

	domain_name = node.attribute["domain_name"]
	type = node.attribute["type"]
	zone_name = node.attribute["zone_name"]

end

attributes = {
	:provider => 'AWS',
	:aws_access_key_id => 'AKIAIEBFCK7OBILTWJBA',
	:aws_secret_access_key => '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',
}

dns = Fog::DNS.new(attributes)
aws = Fog::Compute.new(attributes)

server = aws.servers.get(instance_id)


if server.nil?
	Process.exit
end

zone_id = nil
options= { :max_items => 200 }
response = dns.list_hosted_zones(options)

main_zone = nil

if response.status == 200
  zones = response.body['HostedZones']
  zones.each { |zone|
	domain_name = zone['Name']
	zone_id = zone['Id']
	main_zone = zone
  }
end

if zone_id.nil?
	response = dns.create_hosted_zone(domain_name + ".")
	if response.status == 201
		zone = response.body['HostedZone']
		zone_id = zone['Id']
		main_zone = zone
	else
		puts "Error trying to crete hosted zone"
		Process.exit
	end
end

fqdnInt = server.tags["Name"] + ".int." + domain_name
fqdnExt = server.tags["Name"] + ".ext." + domain_name

intIpAddress = "#{server.private_ip_address}"
extIpAddress = "#{server.public_ip_address}"

if type.eql?("MX")
	intIpAddress = "10 " + intIpAddress
	extIpAddress = "10 " + extIpAddress
end

record = { :name => fqdnInt, :type => type, :ttl => 3600, :resource_records => [intIpAddress], :action => "CREATE" }

change_batch = [record]
options = { :comment => "Change #{type} record for #{fqdnInt}"}
response = dns.change_resource_record_sets( zone_id, change_batch, options)
if response.status == 200
  change_id = response.body['Id']
  status = response.body['Status']
end

record = { :name => fqdnExt, :type => type, :ttl => 3600, :resource_records => [extIpAddress], :action => "CREATE" }

change_batch = [record]
options = { :comment => "Change #{type} record for #{fqdnExt}"}
response = dns.change_resource_record_sets( zone_id, change_batch, options)
if response.status == 200
  change_id = response.body['Id']
  status = response.body['Status']
end
