#
# Cookbook Name:: solr
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w["solr-common", "solr-jetty"].each |pkg|
  package pkg do
  action :install
  end
end
