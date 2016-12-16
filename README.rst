Alignak demonstration server
############################

*Setting-up a demonstration server for Alignak monitoring framework ...*

This repository contains many stuff for Alignak:

  - demo configuration to set-up a demo server (the one used for http://demo.alignak.net)

  - some various tests configurations (each having a README to explain what they are made for)

  - scripts to run the Alignak daemons for the demo server (may be used for other configurations)

  - a script to create, delete and get elements in the alignak backend


What's behind the backend script
================================

This simple script may be used to make simple operations with the Alignak backend:

  - create a new element based (or not) on a template

  - delete an element

  - get an element and dump its properties to the console or a file (in /tmp)


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

    # The script dumps the json host on the console and creates a file: */tmp/alignak-object-dump-host-test_host_0*
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

    # Delete an host from the backend
    backend_client -T windows-nsca-host -t host delete myHost
    # The script inform on the console
        Deleted host 'myHost'


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

Requirements
------------
The scripts provided with this demo use the `screen` utility found on all Linux/Unix distro. As such::

  sudo apt-get install screen

.. note:: It is not mandatory to use the provided scripts, but it is more simple for a first try;)


Setting-up the demo
===================

Get all components
------------------

.. note:: All the Alignak components need a root account (or *sudo* privilege) to get installed.

Get base components::

  mkdir ~/repos
  cd ~/repos

  adduser alignak
  adduser alignak sudo

  # Alignak framework
  git clone https://github.com/Alignak-monitoring/alignak
  cd alignak
  pip install -r requirements.txt
  python setup.py install
  # User permissions
  sudo chown -R alignak:alignak /usr/local/var/run/alignak
  sudo chown -R alignak:alignak /usr/local/var/log/alignak
  sudo chown -R alignak:alignak /usr/local/etc/alignak

  # uwsgihi ddurieux
  sudo apt-get install uwsgi uwsgi-plugin-python

  # Alignak backend
  git clone https://github.com/Alignak-monitoring-contrib/alignak-backend
  cd alignak-backend
  pip install -r requirements.txt
  python setup.py install


  # Alignak WebUI
  git clone https://github.com/Alignak-monitoring-contrib/alignak-webui
  cd alignak-webui
  pip install -r requirements.txt
  python setup.py install


Get Alignak modules/checks setup utility (useful to install all the components)::

  pip install alignak-setup


Get Alignak modules::

  pip install alignak-module-backend
  pip install alignak-module-nsca
  pip install alignak-module-logs
  pip install alignak-module-ws
  # Note that the default module configuration is not suitable, but it will be installed later...


Get checks packages::

  pip install alignak-checks-monitoring
  pip install alignak-checks-mysql
  pip install alignak-checks-nrpe
  pip install alignak-checks-snmp
  pip install alignak-checks-windows-nsca
  pip install alignak-checks-wmi
  # Note that the default packs configuration is not suitable, but it will be installed later...


Configure Alignak
-----------------

This repository contains a default demo configuration that uses all the previously installed components::

  # Alignak demo configuration
  git clone https://github.com/Alignak-monitoring-contrib/alignak-demo
  cp -R alignak-demo/etc/* /usr/local/etc/alignak/.
  python setup.py install


Configure/run Alignak backend
-----------------------------
Update the *(/usr/local)/etc/alignak-backend/settings.json* configuration file to set-up the parameters:

  * mongo DB parameters
  * graphite / grafana parameters

.. note:: the default parameters are suitable for a simple demo.

Run the Alignak backend::

  cd ~/repos/alignak-backend
  ./bin/run.sh


Feed the Alignak backend
------------------------
Run the Alignak backend import script to push the demo configuration into the backend:

  alignak-backend-import -m /usr/local/etc/alignak/alignak-backend-import.cfg

.. note:: there are other solution to feed the Alignak backend but we choose to show how to get an existing configuration and import this configuration in the Alignak backend to migrate from an existing Nagios/Shinken to Alignak.


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