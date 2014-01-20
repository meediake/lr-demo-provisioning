
USER=node['selenium']['user']

group USER

user USER do
  comment "selenium user"
  gid USER
  #system true
  shell "/bin/bash"
  home node['selenium']['home']
end

#folder for pids
directory '/var/run/selenium' do
  mode "0775"
  owner "root"
  group "root"
  action :create
  recursive true
end

directory node['selenium']['server']['installpath'] do
  owner USER
  recursive true
end

directory node['selenium']['home']+'init/' do
  mode "0775"
  owner USER
  group USER
  action :create
  recursive true
end

unless node['downloads_enabled']

  remote_file File.join(node['selenium']['server']['installpath'], 'selenium-server-standalone.jar') do
    source "http://selenium.googlecode.com/files/selenium-server-standalone-#{node['selenium']['server']['version']}.jar"
    action :create_if_missing
    mode 0644
    owner USER
    group USER
  end

end