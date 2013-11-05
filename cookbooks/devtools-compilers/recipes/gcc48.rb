
%w{gcc-4.8 g++-4.8}.each do |pkg|
  package pkg do
    action :install
  end
end

bash "update-alternatives-gxx" do
  user "root"
  code <<-EOF
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50
EOF
end
