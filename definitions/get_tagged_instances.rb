#
# Cookbook Name:: ec2-tools
# Definition:: get_tagged_instances

define :get_tagged_instances, :environment => nil, :role => nil do
  return_value = Hash.new
  environment = params[:environment]
  role = params[:role]
  if environment == nil || role == nil
    if environment == nil
      Chef::Log.error "No environment attribute set for definition: find_single_instance[#{params[:name]}]"
    end
    if role == nil
      Chef::Log.error "No role attribute set for definition: find_single_instance[#{params[:name]}]"
    end
  else
    envlist = Hash.new
    taglist = %x[ec2-describe-tags --private-key /home/ubuntu/pk-tag_access.pem --cert /home/ubuntu/cert-tag_access.pem | grep Environment | grep #{params[:environment]} | cut -f3]
#TODO instead of a loop use a single ec2-describe-instances (for qa env this loop takes about one minute!!!)
    taglist.each do |taginfo|
      instance = taginfo.chomp!
      privatedns = %x[ec2-describe-instances --private-key /home/ubuntu/pk-tag_access.pem --cert /home/ubuntu/cert-tag_access.pem #{instance} | grep INSTANCE | cut -f5]
      envlist[instance] = privatedns
    end
    taglist = %x[ec2-describe-tags --private-key /home/ubuntu/pk-tag_access.pem --cert /home/ubuntu/cert-tag_access.pem | grep Role | grep #{params[:role]} | cut -f3]
    taglist.each do |taginfo|
      instance = taginfo.chomp!
      privatedns = %x[ec2-describe-instances --private-key /home/ubuntu/pk-tag_access.pem --cert /home/ubuntu/cert-tag_access.pem #{instance} | grep INSTANCE | cut -f5]
      privatedns = privatedns.chomp!
      if envlist[instance] != nil && privatedns != nil && privatedns.length > 0
        return_value[instance] = privatedns
      end
    end
  end
  return_value
end

