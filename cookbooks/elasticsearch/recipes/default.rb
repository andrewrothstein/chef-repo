[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

Erubis::Context.send(:include, Extensions::Templates)

elasticsearch = "elasticsearch-#{node.elasticsearch[:version]}"

include_recipe "elasticsearch::curl"
include_recipe "ark"

# Create user and group
#
group node.elasticsearch[:user] do
  action :create
end

user node.elasticsearch[:user] do
  comment "ElasticSearch User"
  home    "#{node.elasticsearch[:dir]}/elasticsearch"
  shell   "/bin/bash"
  gid     node.elasticsearch[:user]
  supports :manage_home => false
  action  :create
end

# FIX: Work around the fact that Chef creates the directory even for `manage_home: false`
bash "remove the elasticsearch user home" do
  user    'root'
  code    "rm -rf  #{node.elasticsearch[:dir]}/elasticsearch"

  not_if  "test -L #{node.elasticsearch[:dir]}/elasticsearch"
  only_if "test -d #{node.elasticsearch[:dir]}/elasticsearch"
end

# Create ES directories
#
[ node.elasticsearch[:path][:conf], node.elasticsearch[:path][:logs], node.elasticsearch[:pid_path] ].each do |path|
  directory path do
    owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
    recursive true
    action :create
  end
end

# Create data path directories
#
data_paths = node.elasticsearch[:path][:data].is_a?(Array) ? node.elasticsearch[:path][:data] : node.elasticsearch[:path][:data].split(',')

data_paths.each do |path|
  directory path.strip do
    owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755
    recursive true
    action :create
  end
end

# Create service
#
template "/etc/init.d/elasticsearch" do
  source "elasticsearch.init.erb"
  owner 'root' and mode 0755
end

service "elasticsearch" do
  supports :status => true, :restart => true
  action [ :enable ]
end

# Download, extract, symlink the elasticsearch libraries and binaries
#
ark_prefix_root = node.elasticsearch[:dir] || node.ark[:prefix_root]
ark_prefix_home = node.elasticsearch[:dir] || node.ark[:prefix_home]

ark "elasticsearch" do
  url   node.elasticsearch[:download_url]
  owner node.elasticsearch[:user]
  group node.elasticsearch[:user]
  version node.elasticsearch[:version]
  has_binaries ['bin/elasticsearch', 'bin/plugin']
  checksum node.elasticsearch[:checksum]
  prefix_root   ark_prefix_root
  prefix_home   ark_prefix_home

  notifies :start,   'service[elasticsearch]'
  notifies :restart, 'service[elasticsearch]'

  not_if do
    link   = "#{node.elasticsearch[:dir]}/elasticsearch"
    target = "#{node.elasticsearch[:dir]}/elasticsearch-#{node.elasticsearch[:version]}"
    binary = "#{target}/bin/elasticsearch"

    ::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target && ::File.exists?(binary)
  end
end

# Increase open file and memory limits
#
bash "enable user limits" do
  user 'root'

  code <<-END.gsub(/^    /, '')
    echo 'session    required   pam_limits.so' >> /etc/pam.d/su
  END

  not_if { ::File.read("/etc/pam.d/su").match(/^session    required   pam_limits\.so/) }
end

log "increase limits for the elasticsearch user"

file "/etc/security/limits.d/10-elasticsearch.conf" do
  content <<-END.gsub(/^    /, '')
    #{node.elasticsearch.fetch(:user, "elasticsearch")}     -    nofile    #{node.elasticsearch[:limits][:nofile]}
    #{node.elasticsearch.fetch(:user, "elasticsearch")}     -    memlock   #{node.elasticsearch[:limits][:memlock]}
  END
end

# Create file with ES environment variables
#
template "elasticsearch-env.sh" do
  path   "#{node.elasticsearch[:path][:conf]}/elasticsearch-env.sh"
  source "elasticsearch-env.sh.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755

  notifies :restart, 'service[elasticsearch]'
end

# Create ES config file
#
template "elasticsearch.yml" do
  path   "#{node.elasticsearch[:path][:conf]}/elasticsearch.yml"
  source "elasticsearch.yml.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755

  notifies :restart, 'service[elasticsearch]'
end

# Create ES logging file
#
template "logging.yml" do
  path   "#{node.elasticsearch[:path][:conf]}/logging.yml"
  source "logging.yml.erb"
  owner node.elasticsearch[:user] and group node.elasticsearch[:user] and mode 0755

  notifies :restart, 'service[elasticsearch]'
end