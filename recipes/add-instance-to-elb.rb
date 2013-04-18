#!/usr/bin/env ruby

# Run with  ruby -rubygems add-instance-to-elb.rb storefront i-0aeb7d6a us-east-1
#	elb_id = "storefront"
#	instance_id = "i-0aeb7d6a"
#	region = "us-east-1"

require 'fog'

unless defined? node
	elb_id = ARGV[0]
	instance_id = ARGV[1]
	region = ARGV[2]
else
	elb_id = node.attribute["elb_id"]
	region = node.attribute["region"]

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
end


attributes = {
	:aws_access_key_id => 'AKIAJBQME4ZIHUI4KBBA',
	:aws_secret_access_key => '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',
	:region => region
}

elb = Fog::AWS::ELB.new(attributes)
elb.register_instances_with_load_balancer(instance_id, elb_id)

