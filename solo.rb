log_level :info
log_location STDOUT
cookbook_path [ File.expand_path('../cookbooks', __FILE__) ]
role_path [ File.expand_path('../roles', __FILE__) ]
json_attribs File.expand_path('../solo.json', __FILE__)
