include_recipe "liverebel-sshkey"

standalone_agent_user = node['liverebel']['agent']['user']
standalone_agent_group = node['liverebel']['agent']['group']
standalone_agent_type = node['liverebel']['agent']['type']
standalone_agent_user_home = "/opt/#{standalone_agent_user}"
standalone_agent_installer_jar = "lr-#{standalone_agent_type}-installer.jar"
standalone_agent_installer_jar_path = "#{standalone_agent_user_home}/#{standalone_agent_installer_jar}"
standalone_agent_installed_path = "#{standalone_agent_user_home}/lr-agent"

user "create_standalone_agent_user" do
  comment "LiveRebel agent user"
  username standalone_agent_user
  home "#{standalone_agent_user_home}"
  manage_home true
  if standalone_agent_group
    gid standalone_agent_group
  end
  shell "/bin/bash"
  action :create
end

ruby_block 'update-standalone-agent-properties' do
  action :nothing
  block do
    file = Chef::Util::FileEdit.new("#{standalone_agent_installed_path}/conf/lr-agent.properties")
    file.insert_line_if_no_match("/agent\\.host/", "agent.host=#{node['liverebel']['agentip']}")
    file.write_file
    if node['liverebel']['agent']['type'] == 'proxy'
      file.insert_line_if_no_match("/liverebel\\.agent\\.http\\.session\\.cookieName/", "liverebel.agent.http.session.cookieName=PHPSESSID")
      file.write_file
      file.insert_line_if_no_match("/liverebel\\.agent\\.http\\.session\\.uriName/", "liverebel.agent.http.session.uriName=PHPSESSID")
      file.write_file
      file.insert_line_if_no_match("/liverebel\\.agent\\.proxy\\.http\\.bind\\.port/", "liverebel.agent.proxy.http.bind.port=9090")
      file.write_file
      file.insert_line_if_no_match("/liverebel\\.agent\\.proxy\\.http\\.forward\\.port/", "liverebel.agent.proxy.http.forward.port=80")
      file.write_file
      file.insert_line_if_no_match("/liverebel\\.agent\\.proxy\\.http\\.bind\\.host/", "liverebel.agent.proxy.http.bind.host=#{node['liverebel']['agentip']}")
      file.write_file
      file.insert_line_if_no_match("/liverebel\\.agent\\.proxy\\.http\\.forward\\.host/", "liverebel.agent.proxy.http.forward.host=#{node['liverebel']['agentip']}")
      file.write_file
      file.insert_line_if_no_match("/liverebel\\.preferredGroup/", "liverebel.preferredGroup=Answers-PHP")
      file.write_file
    end
  end
end

execute "install-standalone-agent" do
  cwd standalone_agent_user_home
  user standalone_agent_user
  command "/usr/bin/java -Dliverebel.agent.token=vagrant -Dliverebel.host=#{node['liverebel']['hostip']} -jar #{standalone_agent_installer_jar_path}"
  action :nothing
  notifies :create, "ruby_block[update-standalone-agent-properties]", :immediately
  not_if do
    File.exists?(standalone_agent_installed_path)
  end
end

remote_file standalone_agent_installer_jar_path do
  source "https://#{node['liverebel']['hostip']}:9001/public/#{standalone_agent_installer_jar}"
  owner standalone_agent_user
  mode 00644
  notifies :run, "execute[install-standalone-agent]", :immediately
  not_if do
    node["liverebel"]["install_agents"] != 'On' || File.exists?(standalone_agent_installer_jar_path)
  end
end

case node["platform"]
when "debian","ubuntu"
  template "/etc/init.d/lragent" do
    source "init-debian.erb"
    owner "root"
    group "root"
    mode "0755"
    variables(
      :lragent_user => standalone_agent_user,
      :lragent_home => standalone_agent_installed_path
    )
  end
  execute "init-deb" do
    user "root"
    group "root"
    command "update-rc.d lragent defaults"
    action :run
    end
end

service "lragent" do
    service_name "lragent"
    action :start
    not_if do
      node["liverebel"]["install_agents"] != 'On'
    end
end

# install the vagrant private ssh key

vagrant_sshkey standalone_agent_user_home do
  owner standalone_agent_user
  group standalone_agent_group
end

# store the tunnel port in a file

template "#{standalone_agent_user_home}/tunnelport" do
  source "tunnelport.erb"
  owner standalone_agent_user
  group standalone_agent_group
  mode 00640
end
