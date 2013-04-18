#
# Cookbook Name:: ec2-tools
# Definition:: find_servers

define :find_servers, :environment => nil, :role => nil do
  return_value = Hash.new
  environment = params[:environment]
  role = params[:role]
  if environment == nil || role == nil
    if environment == nil
      Chef::Log.error "No environment attribute set for definition: find_servers[#{params[:name]}]"
    end
    if role == nil
      Chef::Log.error "No role attribute set for definition: find_servers[#{params[:name]}]"
    end
  else

##TODO: implement for multiple servers

    if File.exists?("/home/ubuntu/roles-#{environment}.prop")
      Chef::Log.info "Server search via property file for role: " + role
      servers = Hash[File.read("/home/ubuntu/roles-#{environment}.prop").split("\n").map{|i|i.split('=')}]
      if servers[role] != nil
        return_value[servers[role]] = servers[role]
        Chef::Log.info "Found server in property file: " + servers[role]
      end
    end
    if return_value.size == 0
#For non-EC2 nodes use the Chef search
      if (node[:ec2] == nil) || (node[:ec2tag][:search] == true)
        Chef::Log.info "Server search via Chef repository for role: " + role
        search(:node, "role:#{role} AND role:#{environment}") do |z|
          if (node[:ec2] == nil)
            return_value[z[:hostname]] = z[:fqdn]
          else
            return_value[z[:ec2][:instance_id]] = z[:fqdn]
          end
        end
      else
#For EC2-nodes use tag for searching instances
        Chef::Log.info "Server search via EC2 tags for role: " + role
        return_value = get_tagged_instances "#{params[:name]}" do
          environment environment
          role role
          return_value return_value
        end
      end
    end
    if return_value.length > 0
      servers = ""
      return_value.keys.each do |instance|
	servers = servers + "[" + instance + "] " + return_value[instance] + "    "
      end
      Chef::Log.info "Found server: #{params[:name]} " + servers
    end
  end
  return_value
end

