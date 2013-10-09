log_level :info
log_location STDOUT
node_name 'solo'
client_key "#{ENV['HOME']}/.chef/#{user}.pem"
cache_type 'BasicFile'
cache_options( :path => File.expand_path('../checksums', __FILE__))
cookbook_path [ File.expand_path('../../cookbooks', __FILE__) ]

# Amazon AWS
knife[:aws_access_key_id] = ENV['AWS_ACCESS_KEY_ID']
knife[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']

# Rackspace Cloud
knife[:rackspace_api_username] = ENV['RACKSPACE_USERNAME']
knife[:rackspace_api_key] = ENV['RACKSPACE_API_KEY']
