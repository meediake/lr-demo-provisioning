Set up the demo environment
===========================

* download and install LiveRebel: http://zeroturnaround.com/liverebel
* download and install Oracle VirtualBox: https://www.virtualbox.org
* download and install Vagrant (at least v1.1) : http://www.vagrantup.com

* note that when using Vagrant 1.0.6 on Windows with Cygwin, there's a known bug
  regarding Unix type paths and Windows paths. This forum posts gives an easy
  fix that can be used until a new version of Vagrant is released:
  https://groups.google.com/forum/#!msg/vagrant-up/UEixJVaHYMw/cmMHmLxLxGEJ

* download and add the precise32 Vagrant box:

    ```bash
    $ vagrant box add precise32 http://files.vagrantup.com/precise32.box
    ```

* start LiveRebel:

    ```bash
    On Unix    $ ./bin/lr-command-center.sh run
    On Windows $ bin\lr-command-center.cmd run
    ```

* check it's running by open this URL in your browser, keep it open:

    ```
    https://localhost:9001
    ```

* provide a LiveRebel license (free or commercial)

* create your first admin in LiveRebel

* for the next steps it's important that you have no firewall blocking incoming
  http and https traffic to Java applications, otherwise it will not be
  possible to connect from the virtual machines to your local LiveRebel 
  installation
    * on Windows 7, you can try the following to disable the firewall only on the virtual network:
        * open "Windows Firewall with Advanced Security"
        * open "Windows Firewall Properties"
        * switch to the tab of the profile your connection is using (or apply the following steps to all three just to be sure)
        * next to "Protected network connections", press the "Customize..." button
        * uncheck the "VirtualBox Host-Only Network"

* if you want to use the Facebook login feature of the demo applications, you
  will need to add the following entries to your local host name database
  (Unix/Linux: `/etc/hosts`; Windows: `C:\Windows\System32\drivers\etc`)
  on the machine on which you're using the web browser:

    ```
    10.127.128.1 host.answers.liverebel.com
    10.127.128.2 java.answers.liverebel.com
    10.127.128.3 java1.answers.liverebel.com
    10.127.128.4 java2.answers.liverebel.com
    10.127.128.5 php.answers.liverebel.com
    10.127.128.6 php1.answers.liverebel.com
    10.127.128.7 php2.answers.liverebel.com
    10.127.128.11 jboss.answers.liverebel.com
    10.127.128.12 jboss1.answers.liverebel.com
    10.127.128.13 jboss2.answers.liverebel.com
    ```
    
* Clone the project with Git:
   ```
   $ git clone https://github. com/zeroturnaround/lr-demo-provisioning.git
   $ git checkout composite # only if you are using composite branch
   ```

Start a PHP cluster
-------------------

* in another terminal start the virtual machines, note that this takes a long
  time since Chef will run the provisioning scripts on each virtual machine
  and download the software that needs to be installed,
  make sure the `lr-demo-provisioning` directory is your current directory:

    ```bash
    $ vagrant up phpcluster php1 php2
    ```

* try the different nodes out in a web browser:

    ```
    http://10.127.128.5/balancer-manager (overview of the load balancer)
    http://10.127.128.6 (default Apache web app of node php1)
    http://10.127.128.7 (default Apache web app of node php2)
    ```

* the PHP nodes automatically download the latest file agent from LiveRebel
  running on your machine outside of Vagrant and start it

* the agents install themselves by using the `vagrant` agent token, go to the
  `Agent tokens` section in the global `Settings` and accept that token:

    ```
    https://localhost:9001/agenttokens
    ```

* after a short delay, you should see two file servers and one database server
  in the LiveRebel Command Center at:

    ```
    https://localhost:9001/servers
    ```

* if you don't have the archives for the PHP demo application, you can either
  build them from the relevant Git repo (https://github.com/zeroturnaround/lr-demo-answers-php)
  or download the latest pre-packaged ones from our DropBox
  (https://www.dropbox.com/sh/sq5wiz95grozldb/ZchlKVZCi-)
  note that these change over time as the provisioning environment evolves,
  make sure you have the latest ones

* now you can deploy the `lr-demo-answers-php` PHP application through LiveRebel in
  both configured Apache servers and the database server, these are the steps:

  * install the MySQL JDBC driver for database migrations by going to the
    `Database drivers` section in LiveRebel's `Configuration` panel,
    you can download the driver from here:

    ```
    http://dev.mysql.com/downloads/connector/j/
    ```

  * configure the MySQL server in LiveRebel by going to the `Servers` tab and
    clicking on `Details` next to `Database server`, these are the connection
    details:

    ```
    Driver: MySQL
    Host: 10.127.128.5 : 3306 / answers
    Username: answers  Password: change_me
    ```
  
  * go to the LiveRebel `Applications` tab and press the `Add Application`
    button to upload the four versions of the PHP Answers demo application

  * when the upload is finished, click the `Add Deployment` button to select
    which version you want to deploy (start with v1.0 and upgrade through
    the next versions later on)

  * the deployment path for which the PHP servers are configured
    is `/var/www/lr-demo-answers`, you'll have to enter that in the `Path`
    textfield

  * some application properties will not be known by LiveRebel and you will
    not be able to deploy unless you provide suitable values, below are
    a few example properties that will make the demo application work but
    they need fine-tuning for the mail and Facebook sections:

    ```
    db.url=mysql:host=10.127.128.5;dbname=answers
    db.username=answers
    db.password=change_me
    fb.appId=12345678901234
    fb.appSecret=123456789012a1234567890b12234567
    mail.host=smtp.gmail.com
    mail.username=you@gmail.com
    mail.password=yourpassword
    mail.port=587
    mail.encryption=tls
    ```

  * when the deployment is done, visit the following URL to see the
    application running through the load balancer:

    ```
    http://10.127.128.5
    ```

  * if you set up the hosts database entries, you can visit the following
    address instead and will be able to use the Facebook login feature:

    ```
    http://php.answers.liverebel.com
    ```

Start a Tomcat cluster
----------------------

* in another terminal start the virtual machines, note that this takes a long
  time since Chef will run the provisioning scripts on each virtual machine
  and download the software that needs to be installed,
  make sure the `lr-demo-provisioning` directory is your current directory:

    ```bash
    $ vagrant up tomcatcluster tomcat1 tomcat2
    ```

* try the different nodes out in a web browser:

    ```
    http://10.127.128.2/balancer-manager (overview of the load balancer)
    http://10.127.128.3:8080 (default Tomcat web app of node tomcat1)
    http://10.127.128.4:8080 (default Tomcat web app of node tomcat2)
    ```

* the Tomcat nodes automatically download the latest file agent from LiveRebel
  running on your machine outside of Vagrant and start it


* the agents install themselves by using the `vagrant` agent token, go to the
  `Agent tokens` section in the global `Settings` and accept that token:

    ```
    https://localhost:9001/agenttokens
    ```

* after a short delay, you should see two application servers and one database
  server in the LiveRebel Command Center at:

    ```
    https://localhost:9001/servers
    ```

* the Tomcat service init scripts have also been modified to use the installed
  LiveRebel agent

* if you don't have the archives for the Java demo application, you can either
  build them from the relevant Git repo (https://github.com/zeroturnaround/lr-demo-answers-java)
  or download the latest pre-packaged ones from our DropBox
  (https://www.dropbox.com/sh/sq5wiz95grozldb/ZchlKVZCi-)
  note that these change over time as the provisioning environment evolves,
  make sure you have the latest ones

* now you can deploy the `lr-demo-answers-java` web application through
  LiveRebel in both configured Tomcat servers and the database server, these
  are the steps:

  * install the MySQL JDBC driver for database migrations by going to the
    `Database drivers` section in LiveRebel's `Configuration` panel,
    you can download the driver from here:

    ```
    http://dev.mysql.com/downloads/connector/j/
    ```

  * configure the MySQL server in LiveRebel by going to the `Servers` tab and
    clicking on `Details` next to `Database server`, these are the connection
    details:

    ```
    Driver: MySQL
    Host: 10.127.128.2 : 3306 / answers
    Username: answers  Password: change_me
    ```
  
  * go to the LiveRebel `Applications` tab and press the `Add Application`
    button to upload the four .war versions of the Java Answers demo
    application

  * when the upload is finished, click the `Add Deployment` button to select
    which version you want to deploy (start with v1.0 and upgrade through
    the next versions later on)

  * some application properties will not be known by LiveRebel and you will
    not be able to deploy unless you provide suitable values, below are
    a few example properties that will make the demo application work but
    they need fine-tuning for the mail and Facebook sections:

    ```
    db.url=jdbc:mysql://10.127.128.2:3306/answers
    db.username=answers
    db.password=change_me
    fb.appId=12345678901234
    fb.appSecret=123456789012a1234567890b12234567
    mail.host=smtp.gmail.com
    mail.username=you@gmail.com
    mail.password=yourpassword
    mail.port=587
    mail.authenticate=true
    mail.protocol=smtps
    mail.startttls=true
    ```

  * when the deployment is done, visit the following URL to see the
    application running through the load balancer:

    ```
    http://10.127.128.2/lr-demo-answers-java
    ```

  * if you set up the hosts database entries, you can visit the following
    address instead and will be able to use the Facebook login feature:

    ```
    http://java.answers.liverebel.com/lr-demo-answers-java
    ```


Start a composite cluster
----------------------

* in a terminal start the virtual machines, note that this takes a long
  time since Chef will run the provisioning scripts on each virtual machine
  and download the software that needs to be installed,
  make sure the `lr-demo-provisioning` directory is your current directory:

    ```bash
    $ vagrant up compositecluster composite1 composite2
    ```

* you have to add the following entries to your local host name database
  on Unix-based systems you can simply add these lines to the `/etc/hosts` file
  of the machine on which you're using the web browser:

    ```
    10.127.128.8 java.answers.liverebel.com php.answers.liverebel.com
    10.127.128.9 composite1.answers.liverebel.com
    10.127.128.10 composite2.answers.liverebel.com
    ```

* note that the first host entry above is conflicting with the following
  entries that you might have added when following the instructions at the top
  of this document, you'll have to **remove these entries**:

    ```
    10.127.128.2 java.answers.liverebel.com
    10.127.128.5 php.answers.liverebel.com
    ```

* try the different nodes out in a web browser:

    ```
    http://java.answers.liverebel.com/balancer-manager (overview of the Java load balancer)
    http://php.answers.liverebel.com/balancer-manager (overview of the PHP load balancer)
    http://composite1.answers.liverebel.com:8080 (default Tomcat web app of node composite1)
    http://composite2.answers.liverebel.com:8080 (default Tomcat web app of node composite2)
    http://composite1.answers.liverebel.com (default Apache web app of node composite1)
    http://composite2.answers.liverebel.com (default Apache web app of node composite2)
    ```

* all the nodes automatically download the latest file agent from LiveRebel
  running on your machine outside of Vagrant and start it

* the agents install themselves by using the `vagrant` agent token, go to the
  `Agent tokens` section in the global `Settings` and accept that token:

    ```
    https://localhost:9001/agenttokens
    ```

* after a short delay, you should see two file servers, two application servers
  and one database server in the LiveRebel Command Center at:

    ```
    https://localhost:9001/servers
    ```

* the Tomcat service init scripts have also been modified to use the installed
  LiveRebel agent

* now you can deploy the `lr-demo-answers-java` web application through
  LiveRebel in both configured Tomcat servers and the database server, these
  are the steps:

  * install the MySQL JDBC driver for database migrations by going to the
    `Database drivers` section in LiveRebel's `Configuration` panel,
    you can download the driver from here:

    ```
    http://dev.mysql.com/downloads/connector/j/
    ```

  * configure the MySQL server in LiveRebel by going to the `Servers` tab and
    clicking on `Details` next to `Database server`, these are the connection
    details:

    ```
    Driver: MySQL
    Host: 10.127.128.8 : 3306 / answers_java
    Username: answers_java  Password: change_me
    ```
  
  * go to the LiveRebel `Applications` tab and press the `Add Application`
    button to upload the four .war versions of the Java Answers demo
    application

  * when the upload is finished, click the `Add Deployment` button to select
    which version you want to deploy (start with v1.0 and upgrade through
    the next versions later on)

  * some application properties will not be known by LiveRebel and you will
    not be able to deploy unless you provide suitable values. Note that since
    you're going to manage two different applications in LiveRebel, you'll have
    to put the Tomcat application servers into a dedicated server group to be
    able to provide these properties independenly.
    Below are a few example properties that will make the demo application work
    but they need fine-tuning for the mail and Facebook sections:

    ```
    db.url=jdbc:mysql://10.127.128.8:3306/answers_java
    db.username=answers_java
    db.password=change_me
    fb.appId=12345678901234
    fb.appSecret=123456789012a1234567890b12234567
    mail.host=smtp.gmail.com
    mail.username=you@gmail.com
    mail.password=yourpassword
    mail.port=587
    mail.authenticate=true
    mail.protocol=smtps
    mail.startttls=true
    ```

  * when the deployment is done, visit the following URL to see the
    application running through the load balancer:

    ```
    http://java.answers.liverebel.com/lr-demo-answers-java
    ```

* now you can deploy the `lr-demo-answers-php` PHP application through LiveRebel in
  both configured Apache servers and the database server, these are the steps:

  * configure the PHP MySQL schema in LiveRebel by going to the `Servers` tab and
    clicking on `Details` next to `Database server`, these are the connection
    details:

    ```
    Driver: MySQL
    Host: 10.127.128.8 : 3306 / answers_php
    Username: answers_php  Password: change_me
    ```
  
  * go to the LiveRebel `Applications` tab and press the `Add Application`
    button to upload the four versions of the PHP Answers demo application

  * when the upload is finished, click the `Add Deployment` button to select
    which version you want to deploy (start with v1.0 and upgrade through
    the next versions later on)

  * the deployment path for which the PHP servers are configured
    is `/var/www/lr-demo-answers`, you'll have to enter that in the `Path`
    textfield

  * some application properties will not be known by LiveRebel and you will
    not be able to deploy unless you provide suitable values. Note that since
    you're going to manage two different applications in LiveRebel, you'll have
    to put the file servers into a dedicated server group to be
    able to provide these properties independenly.
    Below are a few example properties that will make the demo application work
    but they need fine-tuning for the mail and Facebook sections:

    ```
    db.url=mysql:host=10.127.128.8;dbname=answers_php
    db.username=answers_php
    db.password=change_me
    fb.appId=12345678901234
    fb.appSecret=123456789012a1234567890b12234567
    mail.host=smtp.gmail.com
    mail.username=you@gmail.com
    mail.password=yourpassword
    mail.port=587
    mail.encryption=tls
    ```

  * when the deployment is done, visit the following URL to see the
    application running through the load balancer:

    ```
    http://php.answers.liverebel.com
    ```

Remarks about the provided files
================================

* the Vagrantfile is the entry point towards the setup of this demo environment

  - make sure that the configured IP addresses aren't conflicting with hosts on
    your local network, if they are, the easiest way to change them if by
    selecting another value for the global `lr_subnet` variable. By default it
    is set to `10.127.128`

  - if you change the configured IP addresses, make sure to also adapt the
    entries in your local hosts database in case you added the mappings that
    were shown at the beginning of the readme

  - your own machine is communicating through a dedicated host-only network with
    the Vagrant nodes, the IP address of your machine is `10.127.128.1`

  - MySQL is set up with `change_me` for its passwords, you might want
    to ... change them :-)

* the LiveRebel agents are installed automatically by default, setting the
  `@lr_install_agents` variable in the Vagrantfile to `false` will bypass the
  agent installation steps. This is only really useful for manually testing
  the agent installation. Note that when doing this, you should also
  manually edit the `lr-agent/conf/lr-agent.properties` files and set the
  `agent.host` property to the IP address of the VM (10.127.128.x) and the
  `liverebel.agent.cc.host` property to the IP address within the virtual
  network on which LiveRebel CC is running (10.127.128.1). This is due to
  multiple virtual network interfaces being created by Vagrant with the first
  one not being the appropriate network.

* the Chef cookbooks prefixed with `liverebel-` have been created or modified
  specifically for this demo environment

* all the other Chef cookbooks are the standard ones that can be obtained from
  http://community.opscode.com/cookbooks

* the insecure private Vagrant keys are automatically downloaded from the
  GitHub repository and set up as the default private key for the Vagrant user
  on each node (``https://github.com/mitchellh/vagrant/tree/master/keys``)

* the public key from the pair above have is added by default by Vagrant to 
  ``/home/vagrant/.ssh/authorized_keys`` on each node, make sure to take this
  into account when you base production machines on this configuration, you'll
  most certainly want to use your own keys

Running composite environment offline
=====================================
To run composite environment offline, you need to install bases boxes built for composite environment.
They were built running Vagrant online and they do not have LR agents installed.

1. Add compositecluster box to your Vagrant:
vagrant box add cluster https://dl.dropboxusercontent.com/u/101633095/lr-demo-boxes/compositecluster.box

2. Add composite box to your Vagrant:
vagrant box add composite https://dl.dropboxusercontent.com/u/101633095/lr-demo-boxes/composite.box

3. Open Vagrantfile and set following variables like here (enable installing agents and disable downloads):
    ```
     @lr_install_agents = true
     @downloads_enabled = false
    ```

4. Run LiveRebel

5. Run Vagrant:
vagrant up composite1 composite2 compositecluster

It should all work without internet connection, all apt and package download operations are disabled. Only configuration
is being written on new virtual machines.
