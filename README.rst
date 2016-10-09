Alignak demonstration server
############################

*Setting-up a demonstration server for Alignak monitoring framework ...*



This demo configuration is built to set-up a demo server


What's behind this demo?
========================

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

Setting-up the demo
===================
  TO DO ...

What is in?
===========

Monitored configuration
-----------------------

On a single server, the monitored configuration is separated in two **realms** (*All* and *North*).
Some hosts are in the *All* realm and others are in the North realm, member of *All* realm.

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

Directory 'scripts'
-------------------

This directory contains some example scripts to start/stop Alignak demonstration components.

**Note**: The sub-directory *bash* is for `bash` shell environments (eg. Ubuntu, Debian, ...) and the *csh* sub-directory is for `C` shell environments (eg. FreeBSD, ...).

**Note**: those scripts assume that you have previously installed the *screen* utility available on all Unix/Linux ...

In each sub-directory, you will find:

  - `alignak_backend_start.sh` to launch Alignak backend
  - `alignak_webui_start.sh` to launch Alignak Web UI
  - `alignak_start.sh` to launch Alignak

Directory 'etc'
---------------

This directory is an Alignak configuration for:

    - loading monitored objects from the Alignak backend

Configuration building logic
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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