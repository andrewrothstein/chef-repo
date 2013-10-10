#
# Cookbook Name:: devtools-vim
# Recipe:: Recipe to install vim from packages
#
# Copyright 2013, Andrew Rothstein, BlackRock
#
# All rights reserved - Do Not Redistribute
#
%w[vim].each do |pkg|
  package pkg do
    action :purge
    end
end
