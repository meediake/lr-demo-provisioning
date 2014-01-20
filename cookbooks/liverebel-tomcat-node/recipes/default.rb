gem_package "vagrant-vbguest" do
  action :install
end

include_recipe "liverebel-sshkey"
include_recipe "liverebel-apt"
include_recipe "java"
include_recipe "liverebel-tomcat7"

tc7user = node["tomcat7"]["user"]
tc7group = node["tomcat7"]["group"]
tc7home = node["tomcat7"]["home"]

liverebel_appserver_agent "#{tc7home}" do
  user tc7user
  group tc7group
end

# Download and install Selenium

selenium_version = "2.31.0"
selenium_zip = "selenium-java-#{selenium_version}.zip"
selenium_zip_path = "#{tc7home}/#{selenium_zip}"
selenium_installed_path = "#{tc7home}/selenium-2.31.0"

execute "install-selenium" do
  cwd tc7home
  user tc7user
  group tc7group
  command "jar xvf #{selenium_zip}"
  action :nothing
  not_if do
    File.exists?(selenium_installed_path) ||
    !node['downloads_enabled']
  end
end

remote_file selenium_zip_path do
  source "#{node['selenium']['base_url']}#{selenium_zip}"
  owner tc7user
  group tc7group
  mode 00644
  notifies :run, "execute[install-selenium]", :immediately
  not_if do
    File.exists?(selenium_zip_path) ||
    !node['downloads_enabled']
  end
end

# install the vagrant private ssh key

vagrant_sshkey tc7home do
  owner tc7user
  group tc7group
end

# store the tunnel port in a file

template "#{tc7home}/tunnelport" do
  source "tunnelport.erb"
  owner tc7user
  group tc7group
  mode 00640
end

# start the tomcat service

service "tomcat7" do
    service_name "tomcat7"
    action :start
    not_if do
      node["liverebel"]["install_agents"] != 'On'
    end
end
