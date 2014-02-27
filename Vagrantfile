# -*- mode: ruby -*-
# vi: set ft=ruby :

# Setting this to false will not install the LiveRebel agents automatically
# note that it will also not start the service scripts since these have been
# modified for the assumption that the agents are correctly installed.
@lr_install_agents = true

# enabled by default, if set to false, downloading packages will be disabled on base boxes, so the enviromnent can be built
# offline.
# please note that then you must have installed base boxes for composite cluster and composite1 and composite2.
# works currently only with composite env.
# before setting it to false, be sure to download and install these boxes:
# 1) Base box for compositecluster:
# vagrant box add cluster https://dl.dropboxusercontent.com/u/101633095/lr-demo-boxes/compositecluster.box
# 2) Base box for composite1 & composite2:
# vagrant box add composite https://dl.dropboxusercontent.com/u/101633095/lr-demo-boxes/composite.box
#
@downloads_enabled = false

# If needed, the IP addresses used can be changed below.
@lr_subnet = "10.127.128"
@lr_ip_host = "#{@lr_subnet}.1"
@lr_ip_compositecluster = "#{@lr_subnet}.8"
@lr_ip_composite1 = "#{@lr_subnet}.9"
@lr_ip_composite2 = "#{@lr_subnet}.10"

# Uncomment to use a specific APT repository, can lead to broken APT packages
# @apt_repository = "http://ftp.estpak.ee/ubuntu/"

@selenium_base_url = "http://selenium.googlecode.com/files/"

Vagrant.configure("2") do |config|
  config.vm.provider "vmware_fusion" do |vf, override|
    vf.gui = false
    vf.vmx["memsize"] = "1024"
    override.vm.box = "precise64_vmware"
  end

  config.vm.provider "virtualbox" do |vb, override|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--memory", 512]
    override.vm.box = "precise32"
  end

  config.vm.define :compositecluster do |config|
    if !@downloads_enabled
      config.vm.provider "virtualbox" do |vb, override|
        override.vm.box = "cluster"
      end
    end
    config.vm.network :private_network, ip: @lr_ip_compositecluster
    config.vm.provision :chef_solo do |chef|
      chef_config(chef)
      chef_apt_config(chef)
      chef_hosts_config_composite(chef)
      chef.add_recipe "liverebel-compositecluster-node"
      chef_cluster_config(chef, @lr_ip_compositecluster)
      chef.json.deep_merge!({
        :cluster => {
          :phpsessionid => "BALANCEID",
          :javasessionid => "JSESSIONID|jsessionid",
          :phpnodeport => 9090,
          :javanodeport => 8080,
          :nodes => [@lr_ip_composite1, @lr_ip_composite2]
        }
      })
    end
  end

  config.vm.define :composite1 do |config|
    chef_composite(config, @lr_ip_composite1, 1)
  end

  config.vm.define :composite2 do |config|
    chef_composite(config, @lr_ip_composite2, 2)
  end
end

def chef_config(chef)
  chef.cookbooks_path = "cookbooks"
  chef.data_bags_path = "data_bags"
  chef.roles_path = "roles"
  chef.json.deep_merge!({
    :downloads_enabled => @downloads_enabled
  })
end

def chef_hosts_config(chef)
  chef.add_recipe "liverebel-hosts"
  chef.json.deep_merge!({
    :hosts => {
      :host => @lr_ip_host,
      :java => @lr_ip_tomcatcluster,
      :java1 => @lr_ip_tomcat1,
      :java2 => @lr_ip_tomcat2,
      :php => @lr_ip_phpcluster,
      :php1 => @lr_ip_php1,
      :php2 => @lr_ip_php2,
      :jboss => @lr_ip_jbosscluster,
      :jboss1 => @lr_ip_jboss1,
      :jboss2 => @lr_ip_jboss2
    }
  })
end

def chef_hosts_config_composite(chef)
  chef.add_recipe "liverebel-hosts"
  chef.json.deep_merge!({
    :hosts => {
      :host => @lr_ip_host,
      :java => @lr_ip_compositecluster,
      :java1 => @lr_ip_composite1,
      :java2 => @lr_ip_composite2,
      :php => @lr_ip_compositecluster,
      :php1 => @lr_ip_composite1,
      :php2 => @lr_ip_composite2,
      :composite1 => @lr_ip_composite1,
      :composite2 => @lr_ip_composite2,
      :jboss => @lr_ip_jbosscluster,
      :jboss1 => @lr_ip_jboss1,
      :jboss2 => @lr_ip_jboss2
    }
  })
end

def chef_apt_config(chef)
  chef.json.deep_merge!({
    :apt => {
      :repository => @apt_repository
    }
  })
end

def chef_cluster_config(chef, ipAddress)
  chef.json.deep_merge!({
    :liverebel => {
      :install_agents => @lr_install_agents ? 'On' : 'Off',
      :hostip => @lr_ip_host,
      :agentip => ipAddress,
      :agent => {
        :user => 'lragent',
        :type => 'database-agent'
      }
    },
    :mysql => {
      :bind_address => ipAddress,
      :allow_remote_root => true,
      :server_user_password => "change_me",
      :server_root_password => "change_me",
      :server_repl_password => "change_me",
      :server_debian_password => "change_me"
    }
  })
end

def chef_tomcat_config(chef, ipAddress, identifier)
  chef.add_recipe "liverebel-tomcat-node"
  chef.json.deep_merge!({
    :liverebel => {
      :install_agents => @lr_install_agents ? 'On' : 'Off',
      :hostip => @lr_ip_host,
      :agentip => ipAddress,
      :tomcat_tunnelport => 18080+identifier
    },
    :tomcat => {
      :jvm_route => identifier
    },
    :selenium => {
      :base_url => @selenium_base_url
    }
  })
end

def chef_php_config(chef, ipAddress, identifier)
  chef.add_recipe "liverebel-php-node"
  chef.json.deep_merge!({
    :liverebel => {
      :install_agents => @lr_install_agents ? 'On' : 'Off',
      :hostip => @lr_ip_host,
      :agentip => ipAddress,
      :php_tunnelport => 19080+identifier,
      :agent => {
        :user => 'lragent',
        :group => 'www-data',
        :type => 'proxy'
      }
    },
    :php => {
      :server_route => identifier
    },
    :phpunit => {
      :install_method => "pear",
      :version => "3.7.14"
    }
  })
end

def chef_tomcat(config, ipAddress, identifier)
  config.vm.network :private_network, ip: ipAddress
  config.vm.provision :chef_solo do |chef|
    chef_config(chef)
    chef_apt_config(chef)
    chef_hosts_config(chef)
    chef_tomcat_config(chef, ipAddress, identifier)
  end
end

def chef_php(config, ipAddress, identifier)
  config.vm.network :private_network, ip: ipAddress
  config.vm.provision :chef_solo do |chef|
    chef_config(chef)
    chef_apt_config(chef)
    chef_hosts_config(chef)
    chef_php_config(chef, ipAddress, identifier)
  end
end

def chef_composite(config, ipAddress, identifier)
  if !@downloads_enabled
    config.vm.provider "virtualbox" do |vb, override|
      override.vm.box = "composite"
    end
  end

  config.vm.network :private_network, ip: ipAddress
  config.vm.provision :chef_solo do |chef|
    chef_config(chef)
    chef_apt_config(chef)
    chef_hosts_config_composite(chef)
    chef_php_config(chef, ipAddress, identifier)
    chef_tomcat_config(chef, ipAddress, identifier)
  end
end

class Hash
  def deep_merge(other_hash, &block)
    dup.deep_merge!(other_hash, &block)
  end

  def deep_merge!(other_hash, &block)
    other_hash.each_pair do |k,v|
      tv = self[k]
      if tv.is_a?(Hash) && v.is_a?(Hash)
        self[k] = tv.deep_merge(v, &block)
      else
        self[k] = block && tv ? block.call(k, tv, v) : v
      end
    end
    self
  end
end
