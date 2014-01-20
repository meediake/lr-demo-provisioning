gem_package "vagrant-vbguest" do
  action :install
end

include_recipe "liverebel-sshkey"
include_recipe "liverebel-apt"
include_recipe "java"
include_recipe "liverebel-jboss7"

jb7user = node["jboss7"]["user"]
jb7group = node["jboss7"]["group"]
jb7home = node["jboss7"]["home"]

liverebel_appserver_agent "#{jb7home}" do
  user jb7user
  group jb7group
end

# Download and install Selenium

selenium_version = "2.31.0"
selenium_zip = "selenium-java-#{selenium_version}.zip"
selenium_zip_path = "#{jb7home}/#{selenium_zip}"
selenium_installed_path = "#{jb7home}/selenium-2.31.0"

unless node['downloads_enabled']

  execute "install-selenium" do
    cwd jb7home
    user jb7user
    group jb7group
    command "jar xvf #{selenium_zip}"
    action :nothing
    not_if do
      File.exists?(selenium_installed_path)
    end
  end

  remote_file selenium_zip_path do
    source "#{node['selenium']['base_url']}#{selenium_zip}"
    owner jb7user
    group jb7group
    mode 00644
    notifies :run, "execute[install-selenium]", :immediately
    not_if do
      File.exists?(selenium_zip_path)
    end
  end

end

# install the vagrant private ssh key

vagrant_sshkey jb7home do
  owner jb7user
  group jb7group
end

# store the tunnel port in a file

template "#{jb7home}/tunnelport" do
  source "tunnelport.erb"
  owner jb7user
  group jb7group
  mode 00640
end

# start the jboss service

service "jboss7" do
    service_name "jboss7"
    action :start
    not_if do
      node["liverebel"]["install_agents"] != 'On'
    end
end
