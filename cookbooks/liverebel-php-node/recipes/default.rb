if node['downloads_enabled']
  gem_package "vagrant-vbguest" do
    action :install
  end
end

include_recipe "liverebel-apt"
include_recipe "java"
include_recipe "php"
include_recipe "phpunit"
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "liverebel-standalone-agent"

if node['downloads_enabled']

  package "php5-mysql" do
    action :install
  end

  package "php5-curl" do
    action :install
  end

  phpch = php_pear_channel "pear.phpunit.de" do
    action :discover
  end

  php_pear "PHPUnit_Story" do
    channel phpch.channel_name
    action :install
  end

  php_pear "DbUnit" do
    channel phpch.channel_name
    action :install
  end

  php_pear "PHPUnit_Selenium" do
    channel phpch.channel_name
    action :install
  end

end

template "#{node['apache']['dir']}/sites-available/lr-demo-answers" do
  source "lr-demo-answers.erb"
  owner "root"
  group node['apache']['root_group']
  mode 00644
  notifies :restart, "service[apache2]"
end

execute "enable-default-site" do
  command "sudo a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end

execute "enable-lr-demo-answers-site" do
  command "sudo a2ensite lr-demo-answers"
  notifies :reload, resources(:service => "apache2"), :delayed
end

directory "/var/www" do
  owner "www-data"
  group "www-data"
  mode 0774
end