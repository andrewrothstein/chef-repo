#
# Cookbook Name:: devtools-compilers
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt"

apt_repository 'ubuntu-toolchain-r' do
  uri 'http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'BA9EF27F'
end

include_recipe "devtools-compilers::gcc48"
