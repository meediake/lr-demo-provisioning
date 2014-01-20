#
# Cookbook Name:: jboss7
# Recipe:: default
#
# Copyright 2013
#

include_recipe "java"
include_recipe "unzip"

jb7ver = node["jboss7"]["version"]
jb7zip = "jboss-as-#{jb7ver}.Final.zip"
jb7url = "http://download.jboss.org/jbossas/7.1/jboss-as-#{jb7ver}.Final/#{jb7zip}"
jb7target = node["jboss7"]["target"]
jb7user = node["jboss7"]["user"]
jb7group = node["jboss7"]["group"]
jb7install = "#{jb7target}/jboss-as-#{jb7ver}.Final"

unless node['downloads_enabled']

  # Create group
  group "#{jb7group}" do
      action :create
  end

  # Create user
  user "#{jb7user}" do
      comment "JBoss user"
      gid "#{jb7group}"
      home "#{jb7target}/jboss"
      shell "/bin/false"
      system true
      action :create
  end

  # Create base folder
  directory jb7install do
      owner "#{jb7user}"
      group "#{jb7group}"
      mode "0755"
      action :create
  end

  # Get the jboss binary
  log "Downloading #{jb7url}"
  remote_file "/tmp/#{jb7zip}" do
      source "#{jb7url}"
      mode "0644"
      action :create
      notifies :run, "execute[unzip]", :immediately
  end

  # Extract
  log "Unzipping /tmp/#{jb7zip}"
  execute "unzip" do
      user "#{jb7user}"
      group "#{jb7group}"
      installation_dir = "#{jb7target}"
      cwd installation_dir
      command "unzip /tmp/#{jb7zip}"
      action :nothing
  end

  # Set the symlink
  link "#{jb7target}/jboss" do
      to "#{jb7install}"
      link_type :symbolic
  end

  # Add the init-script
  case node["platform"]
  when "debian","ubuntu"
      template "/etc/init.d/jboss7" do
          source "init-debian.erb"
          owner "root"
          group "root"
          mode "0755"
      end
      execute "init-deb" do
          user "root"
          group "root"
          command "update-rc.d jboss7 defaults"
          action :run
      end
  end

  # Config from template
  template "#{jb7install}/standalone/configuration/standalone.xml" do
      source "standalone.xml.erb"
      owner "#{jb7user}"
      group "#{jb7group}"
      mode "0644"
  end

end