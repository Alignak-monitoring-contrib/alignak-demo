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


Requirements
------------
The scripts provided with this demo use the `screen` utility found on all Linux/Unix distro. As such::

  sudo apt-get install screen

**Note**: *It is not mandatory to use the provided scripts, but it is more simple for a first try;)*


Setting-up the demo
===================

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
    sudo pip install -v .

    # Create alignak user/group and set correct permissions on installed configuration files
    sudo ./dev/set_permissions.sh

    # Alignak backend
    # You need to have a running Mongo database.
    # See the Alignak backend installation procedure if you need to set one up and running (http://alignak-backend.readthedocs.io/en/develop/install.html)
    sudo pip install alignak_backend

    # Alignak WebUI
    sudo pip install alignak_webui

Get extension components
------------------------

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

    # Note that the default module configuration is not suitable, but it will be installed later...


Get notifications package::

    # Install extra notifications package
    sudo pip install alignak-notifications


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
    sudo pip install alignak-checks-windows-nsca
    # Checks Windows with Microsoft Windows Management Instrumentation
    sudo pip install alignak-checks-wmi

    # Note that the default packs configuration is not always suitable, but it will be installed later...

    # Restore alignak user/group and set correct permissions on installed configuration files
    sudo ./dev/set_permissions.sh

    # Check what is installed (note that I also installed some RC packages...)
    pip freeze | grep alignak
        alignak==0.2
        alignak-backend==0.6.0
        alignak-backend-client==0.5.2
        alignak-backend-import==1.0rc2
        alignak-checks-monitoring==0.3.0
        alignak-checks-mysql==0.3.0
        alignak-checks-nrpe==0.3.1
        alignak-checks-snmp==0.3.5
        alignak-checks-windows-nsca==1.0rc1
        alignak-checks-wmi==0.3.0
        alignak-demo==0.1.3
        alignak-module-backend==0.3.2
        alignak-module-external-commands==0.3.0
        alignak-module-logs==0.3.2
        alignak-module-nsca==0.3.0
        alignak-module-nrpe-booster==0.3.1
        alignak-module-ws==0.3.0
        alignak-notifications==0.3.0

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


For this demonstration, we imagined a distributed configuration in two *realms*: North and South. This is not the default Alignak configuration (*eg. one instance of each daemon in one realm*) and thus it implies declaring and configuring extra daemons. As we are using some modules we also need to declare those modules in the corresponding daemons configuration. Alignak also has some configuration parameters that may be tuned.

If you need more information `about alignak configuration <http://alignak-doc.readthedocs.io/en/update/04-1_alignak_configuration/index.html>`_.

To avoid dealing with all this configuration steps, this repository contains a default demo configuration that uses all (or almost...) the previously installed components.::

    # Alignak demo configuration
    sudo pip install alignak-demo


Once installed, some extra configuration files got copied in the */usr/local/etc/alignak* directory and some pre-existing files were overriden (eg. default daemons configuration). We may now check that the configuration is correctly parsed by Alignak:
::

    # Check Alignak demo configuration
    alignak-arbiter -V -a /usr/local/etc/alignak/alignak.cfg

**Note** *that an ERROR log will be raised because the backend connection is not available. this is correct because we configured to use the backend but did not yet started the backend! Some WARNING logs are also raised because of duplicate items. Both are nothing to take care of...*

This Alignak demo project installs some shell scripts into the Alignak libexec folder. For ease of use, you may copy those scripts in your home directory.
::

    mkdir ~/demo

    cp /usr/local/var/libexec/alignak/bash/* ~/demo
    cp /usr/local/var/libexec/alignak/python/* ~/demo

**Note** *a next version may install those scripts in the home directory but it is not yet possible;)*

**FreeBSD users** have some scripts available in the *csh* sub-directory instead of *bash* :)

As explained previously, the shell scripts that you just copied use the `screen` utility to detach the process execution from the current shell session.

As of now, Alignak is configured and you are ready to run, 3rd step achieved!


Configure, run and feed Alignak backend
---------------------------------------

It is not necessary to change anything in the Alignak backend configuration file except if your MongoDB installation is not a local database configured by default. Else, open the */usr/local)/etc/alignak-backend/settings.json* configuration file to set-up the parameters according to your configuration.

**Note:** *the default parameters are suitable for a simple demo on a single server.*

Run the Alignak backend:
::

  cd ~/demo
  # Detach a screen session identified as "alignak-backend"
  ./alignak_backend_start.sh

  # Joining the backend screen is 'screen -r alignak-backend'
  # Stopping the backend is './alignak_backend_stop.sh'


Run the Alignak backend import script to push the demo configuration into the backend:
::

  alignak-backend-import -d -m /usr/local/etc/alignak/alignak-backend-import.cfg

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

Run Alignak:
::

  cd ~/demo
  # Detach a screen session identified as "alignak-backend"
  ./alignak_demo_start.sh

  # Stopping Alignak is './alignak_demo_stop.sh'

You can follow the Alignak activity thanks to the monitoring events log created  by the Logs module. You can tail the log file:
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

Configure/run Alignak Web UI
----------------------------
Update the *(/usr/local)/etc/alignak-webui/settings.cfg* configuration file to set-up the parameters.

.. note:: the default parameters are suitable for a simple demo.

Run the Alignak WebUI::

  cd ~/repos/alignak-webui
  ./bin/run.sh

Use your Web browser to navigate to http://localhost:5001 and login with *admin* / *admin*


What is in?
===========

Monitored configuration
-----------------------

On a single server, the monitored configuration is separated in three **realms** (*All*, *North* and *South*).
Some hosts are in the *All* realm and others are in the *North* and *South* realm, both sub-realms of *All* realm.

The *All* realm is (let's say...) a primary datacenter where main servers are located.
*North* realm is a logical group for a part of our monitored hosts. This realm may be seen as a secondary site

According to Alignak daemon logic, the master Arbiter dispatches the configuration to the daemons of each realm.
We must declare, for each realm:

  - a scheduler
  - a broker
  - a poller
  - a receiver (not mandatory but we want to have NSCA collector)

In the *All* realm, we find the following hosts:

  - localhost
  - and some others

In the *North* realm, we find some passive hosts checked thanks to NSCA.

In the *South* realm, we find other hosts.


'scripts' directory
-------------------

This directory contains some example scripts to start/stop Alignak demonstration components.

**Note**: The sub-directory *bash* is for `bash` shell environments (eg. Ubuntu, Debian, ...) and the *csh* sub-directory is for `C` shell environments (eg. FreeBSD, ...).

**Note**: those scripts assume that you have previously installed the *screen* utility available on all Unix/Linux ...

In each sub-directory, you will find:

  - `alignak_backend_start.sh` to launch Alignak backend
  - `alignak_webui_start.sh` to launch Alignak Web UI
  - `alignak_start.sh` to launch Alignak with one instance of each daemon (mainly a sample script ...)
  - `alignak_start_all.sh` to launch Alignak with all the necesarry daemons for this configuration
  - `alignak_stop.sh` to stop all the Alignak daemons

'etc' directory
---------------

This directory is an Alignak flat-files configuration for:

  - loading monitored objects from the Alignak backend (file *alignak.backend-import.cfg*)
  - launching Alignak (file *alignak.backend-run.cfg* which is a copy of *alignak.cfg*)

To make the flat-files configuration easier to edit, we choose to :

  - use the standard Alignak configuration directory only for the common elements and the local server
    -> update the default defined localhost

  - create a configuration directory for each realm to define its own:
    - daemons
    - modules
    - hosts
    - contacts

  - create a specific sub-directory in the *packs* directory to define specific:
    - templates,
    - groups,
    - contacts


What we see?
============

Monitored system status
-----------------------
TBC...
  http://demo.alignak.net


Alignak internal metrics
------------------------
  http://grafana.demo.alignak.net
TBC

For techies::

  $cd /usr/local/share/statsd
  $cat alignak.js
    {
      graphitePort: 2003
    , graphiteHost: "10.0.0.10"
    , port: 8125
    , backends: [ "./backends/graphite" ]
    }

  $screen -S statsd
  $node stats.js alignak.js
  $Ctrl+A Ctrl+D

What's behind the backend script
================================

This simple script may be used to make simple operations with the Alignak backend:

- create a new element based (or not) on a template

- update a backend element

- delete an element

- get an element and dump its properties to the console or a file (in /tmp)

- get (and dump) a list of elements

A simple usage example for this script:
::

    # Assuming that you installed: alignak, alignak-backend and alignak-backend-import

    # From the root of this repository
    cd tests/cfg_passive_templates
    # Import the test configuration in the Alignak backend
    alignak-backend-import -d -m ./cfg_passive_templates.cfg
    # The script imports the configuration and makes some console logs:
        alignak_backend_import, inserted elements:
        - 6 command(s)
        - 3 host(s)
        - 3 host_template(s)
        - no hostdependency(s)
        - no hostescalation(s)
        - 12 hostgroup(s)
        - 1 realm(s)
        - 1 service(s)
        - 14 service_template(s)
        - no servicedependency(s)
        - no serviceescalation(s)
        - 12 servicegroup(s)
        - 2 timeperiod(s)
        - 2 user(s)
        - 3 usergroup(s)

    # Get an host from the backend
    backend_client -t host get test_host_0

    # The script dumps the json host on the console and creates a file: */tmp/alignak-object-dump-host-test_host_0.json*
    {
        ...
        "active_checks_enabled": true,
        "address": "127.0.0.1",
        "address6": "",
        "alias": "test_host_0",
        ...
        "customs": {
            "_OSLICENSE": "gpl",
            "_OSTYPE": "gnulinux"
        },
        ...
    }

    # Get the list of all hosts from the backend
    backend_client --list -t host get

    # The script dumps the json list of hosts on the console and creates a file: */tmp/alignak-object-list-hosts.json*
    {
        ...
        "active_checks_enabled": true,
        "address": "127.0.0.1",
        "address6": "",
        "alias": "test_host_0",
        ...
        "customs": {
            "_OSLICENSE": "gpl",
            "_OSTYPE": "gnulinux"
        },
        ...
    }

    # Create an host into the backend
    backend_client -T windows-nsca-host -t host add myHost
    # The script inform on the console
        Created host 'myHost'

    # Create an host into the backend with extra data
    backend_client -T windows-nsca-host -t host --data='/tmp/create_data.json' add myHost
    # The script reads the JSON content of the file /tmp/create_data.json and tries to create
    # the host named myHost with the template and the read data

    # Update an host into the backend
    backend_client -t host --data='/tmp/update_data.json' update myHost
    # The script reads the JSON content of the file /tmp/update_data.json and tries to update
    # the host named myHost with the read data

    # Delete an host from the backend
    backend_client -T windows-nsca-host -t host delete myHost
    # The script inform on the console
        Deleted host 'myHost'


