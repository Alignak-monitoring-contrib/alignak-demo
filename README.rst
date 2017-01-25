Alignak demonstration server
############################

*Setting-up a demonstration server for Alignak monitoring framework ...*

This repository contains many stuff for Alignak:

- demo configuration to set-up a demo server (the one used for http://demo.alignak.net)

- some various tests configurations (each having a README to explain what they are made for)

- scripts to run the Alignak daemons for the demo server (may be used for other configurations)

- a script to create, delete and get elements in the alignak backend


What's behind the demo server
=============================

This demonstration is made to involve the most possible Alignak components on a single node server.

To set-up this demo, you must:

- install Alignak
- install Alignak backend
- install Alignak Web UI
- install Alignak modules (backend and nsca)
- install Alignak checks packs (NRPE, WMI, SNMP, ...)
- import the configuration into the backend
- start the backend, the Web UI and Alignak
- open your web browser and rest for a while looking at what happens :)

**Note**: it is possible to run Alignak without the backend and the WebUI. all the monitoring events are then available in the monitoring logs but, with this small configuration, one will loose the benefits ;)


The monitored configuration
---------------------------

On a single server, the monitored configuration is separated in three **realms** (*All*, *North* and *South*).
Some hosts are in the *All* realm and others are in the *North* and *South* realm, both sub-realms of *All* realm.

The *All* realm is (let's say...) a primary datacenter where main servers are located. *North* and *South* realms are a logical group for a part of our monitored configuration. They may be seen as secondary sites.

According to Alignak daemon logic, the master Arbiter dispatches the configuration to the daemons of each realm and we must declare, for each realm:

- a scheduler
- a broker
- a poller
- a receiver (not mandatory but we want to have NSCA collector)

In the *All* realm, we find the following hosts:

- localhost
- and some others

In the *North* realm, we find some passive hosts checked thanks to NSCA.

In the *South* realm, we find some other hosts.


Requirements
------------
You will need some requirements for setting-up this demonstration:
::

    # Update your server
    sudo apt-get update
    sudo apt-get upgrade

    # Install git and python
    sudo apt-get install git
    sudo apt-get install python2.7 python2.7-dev python-pip

The scripts provided with this demo use the `screen` utility found on all Linux/Unix distro. As such::

    sudo apt-get install screen

Some screen hint and tips:
::

    # Listing the active screens
    screen -ls

    # Joining a screen
    screen -r alignak-backend

    # Leaving a screen (without killing it)
    screen -r alignak-backend
    Ctrl a+d

    # Switching between active screens
    Ctrl a+n

**Note**: *It is not mandatory to use the provided scripts, but it is more simple for a first try;)*


Setting-up the demo
===================

We recommend having an up-to-date system;)
::

  sudo apt-get update

Get base components
-------------------

**Note** that all the Alignak components need a root account (or *sudo* privilege) to get installed.

**Note** that this pitch is based on the current `update-installer` branch of Alignak that is not yet merged on upstream. This branch will be merged for the 1.0 release.

Get base components::

    mkdir ~/repos
    cd ~/repos

    # Needed for the PyOpenSSL / Cryptography dependencies of Alignak
    sudo apt-get install libssl-dev

    # Alignak framework
    git clone https://github.com/Alignak-monitoring/alignak
    cd alignak
    # Install alignak and all its python dependencies
    # -v will activate the verbose mode of pip
    sudo pip install -v .

    # Create alignak user/group and set correct permissions on installed configuration files
    # As of now, this script is not yet merged to the upstream (the commands are listed at the end of the installation script)
    sudo ./dev/set_permissions.sh

    # Alignak backend
    # You need to have a running Mongo database.
    # See the Alignak backend installation procedure if you need to set one up and running (http://alignak-backend.readthedocs.io/en/develop/install.html)
    sudo pip install alignak-backend

    # Alignak backend importation script
    sudo pip install alignak-backend-import

Get extension components
------------------------

Modules
~~~~~~~

Get and install Alignak modules::

    # Those two modules are "almost" necessary for the essential alignak features
    # If you do not install this module, you will not benefit from the Alignak backend features (retention, logs, timeseries, ...)
    sudo pip install alignak-module-backend
    # If you do not install this module, you will miss a log of all the alignak monitoring events: alerts, notifications, ...
    sudo pip install alignak-module-logs

    # Those are optional...
    # Collect passive NSCA checks
    sudo pip install alignak-module-nsca
    # Write external commands (Nagios-like) to a local named file
    sudo pip install alignak-module-external-commands
    # Notify external commands though a WS and get Alignak state with your web browser
    sudo pip install alignak-module-ws
    # Improve NRPE checks
    sudo pip install alignak-module-nrpe-booster

    # Note that the default module configuration is not suitable, but it will be installed later...


Notifications
~~~~~~~~~~~~~

Get notifications package::

    # Install extra notifications package
    sudo pip install alignak-notifications

**Note** *that this pack requires an SMTP server for the mail notifications to be sent out. If none is available you will get WARNING logs and the notifications will not be sent out, but the demo will run anyway :) See later in this document how to configure the mail notifications...*

Checks packages
~~~~~~~~~~~~~~~

Get checks packages::

    # Install checks packages according to the hosts you want to monitor
    # Checks hosts thanks to NRPE Nagios active checks protocol
    sudo pip install alignak-checks-nrpe
    # Checks hosts thanks to old plain SNMP protocol
    sudo pip install alignak-checks-snmp
    # Checks hosts with "open source" Nagios plugins (eg. check_http, check_tcp, ...)
    sudo pip install alignak-checks-monitoring
    # Checks mysql database server
    sudo pip install alignak-checks-mysql
    # Checks Windows passively checked hosts/services (NSClient++ agent)
    # As of now, use ==1.0rc1 to get the correct version
    sudo pip install alignak-checks-windows-nsca
    # Checks Windows with Microsoft Windows Management Instrumentation
    sudo pip install alignak-checks-wmi

    # Note that the default packs configuration is not always suitable, but it will be installed later...

    # Restore alignak user/group and set correct permissions on installed configuration files
    sudo ./dev/set_permissions.sh

Manage Alignak extensions
~~~~~~~~~~~~~~~~~~~~~~~~~

To check what is installed (note that I also installed some RC packages...):
::

    pip freeze | grep alignak
        alignak==0.2
        alignak-app==0.5.1
        alignak-backend==0.8.5.1
        alignak-backend-client==0.6.11.4
        alignak-backend-import==0.7.2
        alignak-checks-monitoring==0.3.0
        alignak-checks-mysql==0.3.0
        alignak-checks-nrpe==0.3.3
        alignak-checks-snmp==0.3.5
        alignak-checks-windows-nsca==1.0rc1
        alignak-checks-wmi==0.3.0
        alignak-demo==0.1.12
        alignak-module-backend==0.3.3
        alignak-module-external-commands==0.3.0
        alignak-module-logs==0.3.3
        alignak-module-nrpe-booster==0.3.1
        alignak-module-nsca==0.2.7
        alignak-module-ws==0.3.2
        alignak-notifications==0.3.1
        alignak-webui==0.6.11

As of now, you installed all the necessary Alignak stuff for starting a demo monitoring application, 1st step achieved!

Install check plugins
---------------------

Some extra installation steps are still necessary because we are using some external plugins and then we need to install them.

The NRPE checks package requires the `check_nrpe` plugin that is commonly available as:
::

    sudo apt-get install nagios-nrpe-plugin

The monitoring checks package requires some extra plugins. Installation and configuration procedure is `available here <https://github.com/Alignak-monitoring-contrib/alignak-checks-monitoring/tree/updates#configuration>`_ or on the Monitoring Plugins project page.

You may instead install the Nagios plugins that are commonly available as:
::

    sudo apt-get install nagios-plugins

As of now, you really installed all the necessary stuff for starting a demo monitoring application, 2nd step achieved!


Configure Alignak and monitored hosts/services
----------------------------------------------

**Note:** *you may configure Alignak on your own and set your proper monitored hosts and declare how to monitor them. This is the usual way for setting-up your monitoring solution... But, as we are in a demo process, and we want to make it simple, this repository has a prepared configuration to help going faster to a demonstration of Alignak features.*


For this demonstration, we imagined a distributed configuration in three *realms*: All, North and South. This is not the default Alignak configuration (*eg. one instance of each daemon in one realm*) and thus it implies declaring and configuring extra daemons. As we are using some modules we also need to declare those modules in the corresponding daemons configuration. Alignak also has some configuration parameters that may be tuned.

If you need more information `about alignak configuration <http://alignak-doc.readthedocs.io/en/update/04-1_alignak_configuration/index.html>`_.

To avoid dealing with all this configuration steps, this repository contains a default demo configuration that uses all (or almost...) the previously installed components.::

    # Alignak demo configuration
    # IMPORTANT: use the --force argument to allow overwriting previously installed files!
    sudo pip install alignak-demo --force


Once installed, some extra configuration files got copied in the */usr/local/etc/alignak* directory and some pre-existing files were overriden (eg. default daemons configuration). We may now check that the configuration is correctly parsed by Alignak:
::

    # Check Alignak demo configuration
    alignak-arbiter -V -a /usr/local/etc/alignak/alignak.cfg

**Note** *that an ERROR log will be raised because the backend connection is not available. this is correct because we configured to use the backend but did not yet started the backend! Some WARNING logs are also raised because of duplicate items. Both are nothing to take care of...*

This Alignak demo project installs some shell scripts into the Alignak libexec folder. For ease of use, you may copy those scripts in your home directory.
::

    mkdir ~/demo

    cp /usr/local/var/libexec/alignak/bash/* ~/demo

**Note** *a next version may install those scripts in the home directory but it is not yet possible;)*

**FreeBSD users** have some scripts available in the *csh* sub-directory instead of *bash* :)

As explained previously, the shell scripts that you just copied use the `screen` utility to detach the process execution from the current shell session.

As of now, Alignak is configured and you are ready to run, 3rd step achieved!


Configure, run and feed Alignak backend
---------------------------------------

It is not necessary to change anything in the Alignak backend configuration file except if your MongoDB installation is not a local database configured by default. Else, open the */usr/local)/etc/alignak-backend/settings.json* configuration file to set-up the parameters according to your configuration.

**Note:** *the default parameters are suitable for a simple demo on a single server.*

start / stop the backend
~~~~~~~~~~~~~~~~~~~~~~~~

Run the Alignak backend:
::

    cd ~/demo
    # Detach a screen session identified as "alignak-backend"
    ./alignak_backend_start.sh
    # This will run the alignak-backend-uwsgi in a screen session. If you do not mind about a
    # backend screen, you should run: alignak-backend-uwsgi

    ps -ef | grep alignak-
        alignak  30166  1087  0 18:42 ?        00:00:00 SCREEN -d -S alignak-backend -m bash -c alignak-backend
        alignak  30168 30166  0 18:42 pts/18   00:00:00 /usr/bin/python /usr/local/bin/alignak-backend

    # Joining the backend screen is 'screen -r alignak-backend'
    # Stopping the backend is './alignak_backend_stop.sh'

    # The alignak backend writes some logs as a Web server does
    tail -f /usr/local/var/log/alignak-backend-error.log
    tail -f /usr/local/var/log/alignak-backend-access.log

The alignak backend runs thanks to uWSGI and its configuration is available in the */usr/local/alignak-backend/uwsgi.ini* where you can define the log files location. You can also configure the Alignak backend to send its internal metrics to a Graphite timeseries database.

**Note** that a Grafana dashboard for the Alignak backend is available in the */usr/local/etc/alignak/sample/grafana* directory created when you installed the alignak-demo package;)


Feed the backend
~~~~~~~~~~~~~~~~

Run the Alignak backend import script to push the demo configuration into the backend:
::

  alignak-backend-import -d /usr/local/etc/alignak/alignak.cfg

**Note**: *there are other solutions to feed the Alignak backend but we choose to show how to get an existing configuration imported in the Alignak backend to migrate from an existing Nagios/Shinken to Alignak.*

Once imported, you can check that the configuration is correctly parsed by Alignak:
::

    # Check Alignak demo configuration
    alignak-arbiter -V -a /usr/local/etc/alignak/alignak.cfg

        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Creating packs for realms
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Number of hosts in the realm North: 2 (distributed in 2 linked packs)
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Number of hosts in the realm South: 3 (distributed in 2 linked packs)
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Number of hosts in the realm All: 7 (distributed in 7 linked packs)
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Number of Contacts : 5
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Number of Hosts : 12
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Number of Services : 305
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Number of Commands : 78
        [2017-01-06 11:57:28 CET] INFO: [alignak.objects.config] Total number of hosts in all realms: 12
        [2017-01-06 11:57:28 CET] INFO: [alignak.daemons.arbiterdaemon] Things look okay - No serious problems were detected during the pre-flight check
        [2017-01-06 11:57:28 CET] INFO: [alignak.daemons.arbiterdaemon] Arbiter checked the configuration

**Note** *because the backend is now started and available, there is no more ERROR raised during the configuration check! You may still have some information about duplicate elements but nothing to take care of...*

As of now, Alignak is ready to start... let us go!

Run Alignak
-----------

Run Alignak:
::

    cd ~/demo
    # Detach several screen sessions identified as "alignak-daemon_name"
    ./alignak_demo_start.sh

    # Stopping Alignak is './alignak_demo_stop.sh'

Processes
~~~~~~~~~

Alignak runs many processes that you can check with:
::

    ps -ef --forest | grep alignak-

        alignak  30166  1087  0 janv.06 ?      00:00:00          \_ SCREEN -d -S alignak-backend -m bash -c alignak-backend
        alignak  30168 30166  0 janv.06 pts/18 00:08:31          |   \_ /usr/bin/python /usr/local/bin/alignak-backend
        alignak  22289  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_north_broker -m bash -c alignak-broker -c /usr/local/etc/alignak/daemons/North/brokerd-north.ini
        alignak  22291 22289  0 09:55 pts/20   00:01:14          |   \_ alignak-broker broker-north
        alignak  22365 22291  0 09:55 pts/20   00:00:03          |       \_ alignak-broker
        alignak  22542 22291  0 09:55 pts/20   00:00:00          |       \_ alignak-broker-north module: backend_broker
        alignak  22292  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_north_poller -m bash -c alignak-poller -c /usr/local/etc/alignak/daemons/North//pollerd-north.ini
        alignak  22296 22292  0 09:55 pts/21   00:00:49          |   \_ alignak-poller poller-north
        alignak  22349 22296  0 09:55 pts/21   00:00:02          |       \_ alignak-poller
        alignak  22601 22296  0 09:55 pts/21   00:00:01          |       \_ alignak-poller-north worker
        alignak  22294  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_north_scheduler -m bash -c alignak-scheduler -c /usr/local/etc/alignak/daemons/North//schedulerd-north.ini
        alignak  22297 22294  0 09:55 pts/22   00:00:52          |   \_ alignak-scheduler scheduler-north
        alignak  22350 22297  0 09:55 pts/22   00:00:00          |       \_ alignak-scheduler
        alignak  22298  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_north_receiver -m bash -c alignak-receiver -c /usr/local/etc/alignak/daemons/North//receiverd-north.ini
        alignak  22300 22298  0 09:55 pts/23   00:00:31          |   \_ alignak-receiver receiver-north
        alignak  22351 22300  0 09:55 pts/23   00:00:00          |       \_ alignak-receiver
        alignak  22600 22300  0 09:55 pts/23   00:00:00          |       \_ alignak-receiver-north module: nsca_north
        alignak  22310  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_south_broker -m bash -c alignak-broker -c /usr/local/etc/alignak/daemons/South/brokerd-south.ini
        alignak  22312 22310  0 09:55 pts/24   00:01:01          |   \_ alignak-broker broker-south
        alignak  22414 22312  0 09:55 pts/24   00:00:03          |       \_ alignak-broker
        alignak  22547 22312  0 09:55 pts/24   00:00:07          |       \_ alignak-broker-south module: backend_broker
        alignak  22313  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_south_poller -m bash -c alignak-poller -c /usr/local/etc/alignak/daemons/South/pollerd-south.ini
        alignak  22315 22313  0 09:55 pts/25   00:01:04          |   \_ alignak-poller poller-south
        alignak  22413 22315  0 09:55 pts/25   00:00:03          |       \_ alignak-poller
        alignak  22616 22315  0 09:55 pts/25   00:00:05          |       \_ alignak-poller-south worker
        alignak  22316  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_south_scheduler -m bash -c alignak-scheduler -c /usr/local/etc/alignak/daemons/South/schedulerd-south.ini
        alignak  22318 22316  0 09:55 pts/26   00:00:53          |   \_ alignak-scheduler scheduler-south
        alignak  22415 22318  0 09:55 pts/26   00:00:00          |       \_ alignak-scheduler
        alignak  22326  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_broker -m bash -c alignak-broker -c /usr/local/etc/alignak/daemons/brokerd.ini
        alignak  22328 22326  1 09:55 pts/27   00:01:48          |   \_ alignak-broker broker-master
        alignak  22469 22328  0 09:55 pts/27   00:00:06          |       \_ alignak-broker
        alignak  22551 22328  0 09:55 pts/27   00:00:31          |       \_ alignak-broker-master module: backend_broker
        alignak  22605 22328  0 09:55 pts/27   00:00:01          |       \_ alignak-broker-master module: logs
        alignak  22329  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_poller -m bash -c alignak-poller -c /usr/local/etc/alignak/daemons/pollerd.ini
        alignak  22331 22329  0 09:55 pts/28   00:00:40          |   \_ alignak-poller poller-master
        alignak  22456 22331  0 09:55 pts/28   00:00:07          |       \_ alignak-poller
        alignak  22614 22331  0 09:55 pts/28   00:00:17          |       \_ alignak-poller-master worker
        alignak  22332  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_scheduler -m bash -c alignak-scheduler -c /usr/local/etc/alignak/daemons/schedulerd.ini
        alignak  22334 22332  0 09:55 pts/29   00:01:20          |   \_ alignak-scheduler scheduler-master
        alignak  22475 22334  0 09:55 pts/29   00:00:00          |       \_ alignak-scheduler
        alignak  22335  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_receiver -m bash -c alignak-receiver -c /usr/local/etc/alignak/daemons/receiverd.ini
        alignak  22337 22335  0 09:55 pts/30   00:00:57          |   \_ alignak-receiver receiver-master
        alignak  22457 22337  0 09:55 pts/30   00:00:00          |       \_ alignak-receiver
        alignak  22555 22337  0 09:55 pts/30   00:00:00          |       \_ alignak-receiver-master module: nsca
        alignak  22338  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_reactionner -m bash -c alignak-reactionner -c /usr/local/etc/alignak/daemons/reactionnerd.ini
        alignak  22340 22338  0 09:55 pts/31   00:00:34          |   \_ alignak-reactionner reactionner-master
        alignak  22484 22340  0 09:55 pts/31   00:00:02          |       \_ alignak-reactionner
        alignak  22611 22340  0 09:55 pts/31   00:00:01          |       \_ alignak-reactionner-master worker
        alignak  22403  1087  0 09:55 ?        00:00:00          \_ SCREEN -d -S alignak_arbiter -m bash -c alignak-arbiter -c /usr/local/etc/alignak/daemons/arbiterd.ini --arbiter /usr/local/etc/alignak/alignak.cfg
        alignak  22404 22403  1 09:55 pts/32   00:02:34          |   \_ alignak-arbiter arbiter-master
        alignak  22514 22404  0 09:55 pts/32   00:00:00          |       \_ alignak-arbiter


Log files
~~~~~~~~~

Each Alignak daemon has its own log file that you can find in the */usr/local/var/log/alignak* folder. If any error happen there will be at least an ERROR log in the corresponding file. You can *tail* the log files or use more sophisticated tools like *multitail* to stay tuned with Alignak activity
::

    # Using tail
    tail -f /usr/local/var/log/alignak/*.log

    # Using multitail
    sudo apt-get install multitail

    multitail -f /usr/local/var/log/alignak/arbiterd.log\
              -f /usr/local/var/log/alignak/brokerd.log \
              -f /usr/local/var/log/alignak/brokerd-north.log \
              -f /usr/local/var/log/alignak/brokerd-south.log \
              -f /usr/local/var/log/alignak/pollerd.log \
              -f /usr/local/var/log/alignak/pollerd-north.log \
              -f /usr/local/var/log/alignak/pollerd-south.log \
              -f /usr/local/var/log/alignak/reactionnerd.log \
              -f /usr/local/var/log/alignak/receiverd.log \
              -f /usr/local/var/log/alignak/receiverd-north.log \
              -f /usr/local/var/log/alignak/schedulerd.log \
              -f /usr/local/var/log/alignak/schedulerd-north.log \
              -f /usr/local/var/log/alignak/schedulerd-south.log


Monitoring events
~~~~~~~~~~~~~~~~~

You can follow the Alignak monitoring activity thanks to the monitoring events log created  by the Logs module. You can *tail* the */usr/local/var/log/alignak/monitoring-logs.log* file:
::

    [1483714809] INFO: CURRENT SERVICE STATE: chazay;System up-to-date;UNKNOWN;HARD;0;
    [1483714809] INFO: CURRENT SERVICE STATE: passive-01;svc_TagReading_C;UNKNOWN;HARD;0;
    [1483714809] INFO: CURRENT SERVICE STATE: passive-01;dev_TouchUI;UNKNOWN;HARD;0;
    [1483714809] INFO: CURRENT SERVICE STATE: denice;Shinken Main Poller;UNKNOWN;HARD;0;
    [1483714809] INFO: CURRENT SERVICE STATE: localhost;Cpu;UNKNOWN;HARD;0;
    [1483714812] INFO: SERVICE ALERT: chazay;CPU;OK;HARD;0;OK - CPU usage is 39% for server chazay.siprossii.com.
    [1483714816] INFO: SERVICE ALERT: alignak_glpi;Zombies;OK;HARD;0;PROCS OK: 0 processes with STATE = Z
    [1483714837] INFO: SERVICE ALERT: chazay;NTP;OK;HARD;0;NTP OK: Offset -0.003250718117 secs
    [1483714851] INFO: SERVICE ALERT: chazay;Memory;OK;HARD;0;Memory OK - 69.7% (23959990272 kB) used
    [1483714853] ERROR: HOST NOTIFICATION: guest;cogny;DOWN;notify-host-by-xmpp;CHECK_NRPE: Received 0 bytes from daemon.  Check the remote server logs for error messages.
    [1483714853] ERROR: HOST NOTIFICATION: imported_admin;cogny;DOWN;notify-host-by-xmpp;CHECK_NRPE: Received 0 bytes from daemon.  Check the remote server logs for error messages.
    [1483714862] INFO: SERVICE ALERT: chazay;I/O stats;OK;HARD;0;OK - data received
    [1483714886] INFO: SERVICE ALERT: chazay;Users;OK;HARD;0;USERS OK - 0 users currently logged in
    [1483714902] INFO: SERVICE ALERT: alignak_glpi;Load;OK;HARD;0;OK - load average: 0.60, 0.54, 0.52
    [1483714903] INFO: SERVICE ALERT: chazay;Firewall routes;OK;HARD;0;PF OK - states: 1316 (6% - limit: 20000)
    [1483714903] INFO: SERVICE ALERT: cogny;Http;OK;HARD;0;HTTP OK: HTTP/1.1 200 OK - 2535 bytes in 0,199 second response time
    [1483714905] INFO: HOST ALERT: alignak_glpi;UP;HARD;0;NRPE v2.15
    [1483714909] ERROR: HOST NOTIFICATION: imported_admin;localhost;DOWN;notify-host-by-xmpp;[Errno 2] No such file or directory
    [1483714909] ERROR: HOST ALERT: localhost;DOWN;HARD;0;[Errno 2] No such file or directory
    [1483714910] ERROR: HOST ALERT: always_down;DOWN;HARD;0;[Errno 2] No such file or directory
    [1483714910] ERROR: HOST NOTIFICATION: imported_admin;always_down;DOWN;notify-host-by-xmpp;[Errno 2] No such file or directory
    [1483714939] INFO: HOST ALERT: chazay;UP;HARD;0;NRPE v2.15
    [1483714966] INFO: SERVICE ALERT: m2m-asso.fr;Http;OK;HARD;0;HTTP OK: HTTP/1.1 200 OK - 6016 bytes in 3,227 second response time

Monitoring events configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This file is a log of all the monitoring activity of Alignak. The *alignak.cfg* allows to define what are the events that are logged to this file. By default, only the active and passive checks ran by Alignak are not logged to this file:
::

    # Monitoring log configuration
    # ---
    # Note that alerts and downtimes are always logged
    # ---
    # Notifications
    # log_notifications=1

    # Services retries
    # log_service_retries=1

    # Hosts retries
    # log_host_retries=1

    # Event handlers
    # log_event_handlers=1

    # Flappings
    # log_flappings=1

    # Snapshots
    # log_snapshots=1

    # External commands
    # log_external_commands=1

    # Active checks
    # log_active_checks=0

    # Passive checks
    # log_passive_checks=0

    # Initial states
    # log_initial_states=1


Configure Alignak notifications
-------------------------------
As explained previously the alignak notifications pack needs to be configured for sending out the mail notifications. This demo configuration is using default parameters for the mail server that may be adapted to your own configuration.

With the default parameters, you will have some WARNING logs in the *schedulerd.log* file, such as:
::

    [2017-01-07 10:00:47 CET] WARNING: [alignak.scheduler] The notification command '/usr/local/var/libexec/alignak/notify_by_email.py -t service -S localhost -ST 25 -SL your_smtp_login -SP your_smtp_password -fh -to guest@localhost -fr alignak@monitoring -nt PROBLEM -hn "alignak_glpi" -ha 176.31.224.51 -sn "Disk /var" -s CRITICAL -ls UNKNOWN -o "NRPE: Command 'check_var' not defined" -dt 0 -db "1483779644.85" -i 2  -p ""' raised an error (exit code=1): 'Traceback (most recent call last):'

To configure the Alignak mail notifications, edit the */usr/local/etc/alignak/arbiter/packs/resource.d/notifications.cfg* file and set the proper parameters for your configuration:
::


    #-- SMTP server configuration
    $SMTP_SERVER$=localhost
    $SMTP_PORT$=25
    $SMTP_LOGIN$=your_smtp_login
    $SMTP_PASSWORD$=your_smtp_password

    # -- Mail configuration
    $MAIL_FROM$=demo.server@alignak.net

You may also adapt the contacts used in this demo configuration else WE will receive you notification mails :). the used contacts are defined as is:

- alignak.administrator@alignak.net, as the administrator contact for the realm All
- north.administrator@alignak.net, as the administrator contact for the realm North
- south.administrator@alignak.net, as the administrator contact for the realm South

You will find their definition in the */usr/local/etc/arbiter/realms* folder, in each realm (All, North,...) *contacts* sub-folder.


Use Alignak Web services
------------------------
The alignak Web Services module exposes some Web Services on the port 8888.

Get the Alignak daemons status:
::

    http://127.0.0.1:8888/alignak_map


Configure/run Alignak Web UI
----------------------------
As of now, your configuration is monitored and you will receive notifications when something is detected as faulty. Everything is under control but why missing having an eye on what's happening in your system with a more sexy interface than tailing a log file and reading emails?

Install the Alignak Web User Interface:
::

    # Alignak WebUI
    sudo pip install alignak-webui


The default installation is suitable for this demonstration but you may update the *(/usr/local)/etc/alignak-webui/settings.cfg* configuration file to adapt this default configuration.

Run the Alignak WebUI:
::

    cd ~/demo
    # Detach a screen session identified as "alignak-webui"
    ./alignak_webui_start.sh
    # This will run the alignak-webui-uwsgi in a screen session. If you do not mind about a
    # backend screen, you should run: alignak-webui-uwsgi

    ps -ef | grep alignak-
        alignak   3625  1429  0 07:32 ?        00:00:00 SCREEN -d -S alignak-webui -m bash -c alignak-webui
        alignak   3627  3625  3 07:32 pts/18   00:00:00 /usr/bin/python /usr/local/bin/alignak-webui

    # Joining the webui screen is 'screen -r alignak-webui'
    # Stopping the webui is './alignak_webui_stop.sh'

    # The alignak webui writes some logs as a Web server does
    tail -f /usr/local/var/log/alignak-webui-error.log
    tail -f /usr/local/var/log/alignak-webui-access.log


Use your Web browser to navigate to http://127.0.0.1:5001 and log in with *admin* / *admin*.

The alignak WebUI runs thanks to uWSGI and its configuration is available in the */usr/local/alignak-webui/uwsgi.ini* where you can define the log files location. You can also configure the Alignak WebUI to send its internal metrics to a Graphite timeseries database.

**Note** that a Grafana dashboard for the Alignak WebUI is available in the */usr/local/etc/alignak/sample/grafana* directory created when you installed the alignak-demo package;)




Configure/run Alignak desktop applet
------------------------------------
Except when you are in Big Brother mode, you almost always do not need a full Web interface as the one provided by the Alignak WebUI. This is why Alignak provides a desktop applet available for Linux and Windows desktops.

Install the Alignak App:
::

    # For Linux users with python2
    sudo apt-get install python-qt4
    # For Linux and Windows users with python3
    pip3 install PyQt5 --user

    # For Windows users, we recommend using python3, else install PyQt from the download page

    # Alignak App
    pip install alignak_app --user

    # As of now, the last version is not yet pip installable, so we:
    git clone https://github.com/Alignak-monitoring-contrib/alignak-app
    cd alignak-app
    pip install . --user

    # Run the app (1st run)
    $HOME/.local/alignak_app/alignak-app start

    # Then you will be able for next runs to
    alignak-app start

The applet will require a username and a password that are the same os the one used for the Web UI (use *admin* / *admin*). Click on the Alignak icon in the desktop toolbar to activate the Alignak-app features: alignak status, host synthesis view, host/services states, ...

A notification popup will appear if something changed in the hosts / services states existing in the Alignak backend.

The default configuration is suitable for this demonstration but you may update the *$HOME/.local/alignak_app/settings.cfg* configuration file that is largely commented.


Configure Alignak backend for timeseries
----------------------------------------

The Alignak backend allows to send collected performance data to a timeseries database. It must be configured to know where to send the timeseries data. Using the backend_client CLI script makes it easy to configure this:
::

    cd ~/demo

    # Get the example configuration files
    cp /usr/local/etc/alignak/sample/backend/* ~/demo


**Note** that it is recommended to stop Alignak when editing the backend configuration :)

If you **do not** intend to use the StatsD daemon, execute these commands:
::

    # Use Alignak backend CLI to add a Grafana instance
    alignak-backend-cli -v add -t grafana --data=example_grafana.json grafana_demo

    # Use Alignak backend to add a Graphite instance
    alignak-backend-cli -v add -t graphite --data=example_graphite.json graphite_demo


If you **do** intend to use the StatsD daemon, execute these commands:
::

    # Use Alignak backend CLI to add a Grafana instance
    alignak-backend-cli -v add -t grafana --data=example_grafana.json grafana_demo

    # Use Alignak backend CLI to add a StatsD instance
    alignak-backend-cli -v add -t statsd --data=example_statsd.json statsd_demo

    # Use Alignak backend to add a Graphite instance
    alignak-backend-cli -v add -t graphite --data=example_graphite_statsd.json graphite_demo

You can edit the *example_*.json* provided files to include your own Graphite / Grafana (or InfluxDB) parameters. For more information see the `Alignak backend documentation <http://alignak-backend.readthedocs.io/en/develop/api.html#timeseries-databases>`_. It will be mandatory to update the Grafana configuration with your own Grafana API key else the backend will not be able to create the Grafana dashboards and panels automatically?

**Note**: `alignak-backend-cli` is coming with the installation of the Alignak backend client.

Upgrading
---------
Some updates are regularly pushed on the different alignak repositories and then you will sometime need to update this demo configuration. Before upgrading the application you should stop Alignak:
::

    cd ~/demo
    # Stop all alignak processes
    ./alignak_demo_stop.sh

    # Check everything is stopped
    ps -ef | grep alignak-

    # Kill remaining processes :)
    pkill alignak-broker


To upgrade all the alignak packages that were installed, you can:
::

    pip install -U pip list | grep alignak | awk '{ print $1}'


To list the currently installed packages and to know if they are up-to-date, you can use this command:
::

    pip list --outdated | grep alignak


To get the list of outdated packages as a pip requirements list:
::

    pip list --outdated --format columns | grep alignak | awk '{printf "%s==%s\n", $1, $3}' > alignak-update.txt

and to update:
::

    pip install -r alignak-update.txt



What we see?
============

Monitored system status
-----------------------

The `Alignak Web UI <http://demo.alignak.net/>`_ running on our demo server allows to view the monitored system status. Have a look here: `http://demo.alignak.net <http://demo.alignak.net>`_. Several login may be used depending on the user role:

* admin / admin, to get logged-in as an Administrator. You will see all the hosts and will be able to execute some commands (acknowledge a problem, schedule a downtime,...)

* northman / north, to get logged-in as a power user in the North realm. You will see all the hosts of the All and North realms and will be able to execute commands.

* southman / south, to get logged-in as a power user in the South realm. You will see all the hosts of the All and South realms and will be able to execute commands.


Alignak internal metrics
------------------------

Alignak maintains its own internal metrics and it is able to send them to a `StatsD server <https://github.com/etsy/statsd>`_.

We are running a `demo Grafana server <http://grafana.demo.alignak.net>`_ that allows to see tha Alignak internal metrics. Several dashboards are available:

* `Alignak internal metrics <http://grafana.demo.alignak.net/dashboard/db/alignak-internal-metrics>`_ shows the statistics provided by Alignak.

* `Graphite server <http://grafana.demo.alignak.net/dashboard/db/graphite-server-carbon-metrics>`_ reports on Carbon/Graphite own monitoring.

**Note** that a Grafana dashboard sample is available in the */usr/local/etc/alignak/sample/grafana* directory created when you installed the alignak-demo package;)

Install node.js on your server according to the recommended installation process. On FreeBSD:
::

    pkg install node

To get the most recent StatsD (if you distro packaging do not provide it, you must clone the git repository:
::

    cd ~/repos
    git clone https://github.com/etsy/statsd

    # Create an alignak.js file with the following content (adapt to your graphite configuration)
    cp exampleConfig.js alignak.js
    cat alignak.js
    {
          graphitePort: 2003
        , graphiteHost: "127.0.0.1"
        , port: 8125
        , backends: [ "./backends/graphite" ]

        /* Do not use any StatsD metric hierarchy */
        , graphite: {
            /* Do not use legacy namespace */
              legacyNamespace: false

            /* Set a global prefix */
            , globalPrefix: "alignak-statsd"

            /* Set empty prefixes */
            , prefixCounter: ""
            , prefixTimer: ""
            , prefixGauge: ""
            , prefixSet: ""

            /* Do not set any global suffix
            , globalSuffix: "_"
            */
        }
    }


    # Start the StatsD daemon in a screen
    $screen -S statsd
    $node stats.js alignak.js
    # And leave the screen...
    $Ctrl+AD

As of now you have a running StatsD daemon that will collect the Alignak internal metrics to feed Graphite.