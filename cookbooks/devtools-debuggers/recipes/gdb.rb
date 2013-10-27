#
# Cookbook Name:: devtools-editors::emacs
# Recipe:: Recipe to install emacs from packages
# but not limited to emacs, vim
#
# Copyright 2013, Andrew Rothstein, BlackRock
#
# All rights reserved - Do Not Redistribute
#
%w{gdb}.each do |pkg|
  package pkg do
    action :install
  end
end
