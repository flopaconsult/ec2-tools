#
# Cookbook Name:: ec2-tools
# Definition:: get_tagged_env_instances

define :get_tagged_env_instances do
  return_value = params[:return_value]
  environment = params[:environment]
  if return_value == nil || environment == nil
    if return_value == nil
      Chef::Log.error "No return_value attribute set for definition: find_single_instance[#{params[:name]}]"
    end 
    if environment == nil
      Chef::Log.error "No environment attribute set for definition: find_single_instance[#{params[:name]}]"
    end
  else
    taglist = %x[ec2-describe-tags --private-key /home/ubuntu/pk-tag_access.pem --cert /home/ubuntu/cert-tag_access.pem | grep Environment | grep #{environment} | cut -f3]
    taglist.each do |taginfo|
      instance = taginfo.chomp!
      privatedns = %x[ec2-describe-instances --private-key /home/ubuntu/pk-tag_access.pem --cert /home/ubuntu/cert-tag_access.pem #{instance} | grep INSTANCE | cut -f5]
      return_value[instance] = privatedns
    end
  end
end

