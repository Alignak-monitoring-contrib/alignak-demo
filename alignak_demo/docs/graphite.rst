Installing Graphite/Grafana
###########################

*Alignak is timeseries friendly...*

This repository contains many stuff for Alignak:

- demo configuration to set-up a demo server (the one used for http://demo.alignak.net)

- some various tests configurations (each having a README to explain what they are made for)

- scripts to run the Alignak daemons for the demo server (may be used for other configurations)


All the procedures in this document are existing in the Alignak documentation which is available on `Read The Docs <http://docs.alignak.net>`_. The aim of this document is simply to contain a simple and easy procedure to set-up a standard configuration demonstrating what Alignak is capable of.


9. Configure Alignak backend for timeseries
-------------------------------------------

The Alignak backend allows to send collected performance data to a timeseries database. It must be configured to know where to send the timeseries data.

**Note**: Using StatsD as a front-end to the Graphite Carbon collector is not mandatory but it will help to have more regular statistics and it will maintain a metrics cache. But the purpose of this doc is not to discuss about the benefits / drawbacks of StatsD...

Using the Alignak WebUI makes it really easy to configure. Navigate to the Web UI Alignak backend menu and select the *Backend Grafana* item. Enter edition mode and add a new item. Also create a new Graphite item related to the Grafana item you just created, and that's it ...

You can also use command line scripts to create such information in the Alignak backend. Using the `alignak-backend-client` script makes it easy to configure this:
::

    cd ~/demo

    # Get the example configuration files
    cp /usr/local/etc/alignak/sample/backend/* ~/demo


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

You can edit the *example_*.json* provided files to include your own Graphite / Grafana (or InfluxDB) parameters. For more information see the `Alignak backend documentation <http://alignak-backend.readthedocs.io/en/develop/api.html#timeseries-databases>`_.

**Warning**: It will be mandatory to update the Grafana configuration with your own Grafana API key else the backend will not be able to create the Grafana dashboards and panels automatically!

**Note**: `alignak-backend-cli` is coming with the installation of the Alignak backend client.

10. Upgrading
-------------
Some updates are regularly pushed on the different alignak repositories and then you will sometime need to update this demo configuration. Before upgrading the application you should stop Alignak:
::

    cd ~/demo
    # Stop all alignak processes
    ./alignak_demo_stop.sh

    # Check everything is stopped
    ps -ef | grep alignak-

    # Kill remaining processes. It may happen on a demo server;)
    pkill alignak-broker


To upgrade Alignak, you can:
::

    cd ~/repos/alignak

    # Get the last develop version
    git pull

    # Install alignak and all its python dependencies
    # -v will activate the verbose mode of pip
    sudo pip install -v .

    # Create alignak user/group and set correct permissions on installed configuration files
    sudo ./dev/set_permissions.sh


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

Alignak maintains its own internal metrics and it is able to send them to a `StatsD server <https://github.com/etsy/statsd>`_. Install the StatsD server locally (as explained later in this document) and update the `alignak.cfg` configuration file to enable this feature:
::

   # Export all alignak inner performances into a statsd server.
   # By default at localhost:8125 (UDP) with the alignak prefix
   # Default is not enabled
   statsd_host=localhost
   #statsd_port=8125
   statsd_prefix=alignak
   statsd_enabled=1


We are running a `demo Grafana server <http://grafana.demo.alignak.net>`_ that allows to see the Alignak internal metrics. Several dashboards are available:

* `Alignak internal metrics <http://grafana.demo.alignak.net/dashboard/db/alignak-internal-metrics>`_ shows the statistics provided by Alignak. This sample dashboard is available in the Alignak repository, *contrib* folder.

* `Graphite server <http://grafana.demo.alignak.net/dashboard/db/graphite-server-carbon-metrics>`_ reports on Carbon/Graphite own monitoring. This dashboard is available from the Grafana.net web site.



Installing StatsD / Graphite / Grafana
--------------------------------------

**NOTE** this section is a draft chapter. Currently the installatin described here is not fully functional !

StatsD
~~~~~~
Install node.js on your server according to the recommended installation process.

On FreeBSD:
::

    pkg install node

On Ubuntu / Debian:
::

    # For Node.js 6
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs

To get the most recent StatsD (if you distro packaging do not provide it, you must clone the git repository:
::

    $ cd ~
    $ git clone https://github.com/etsy/statsd
    $ cd statsd

    # Create an alignak.js file with the following content (for a localhost Graphite)
    $ cp exampleConfig.js alignak.js
    $ cat alignak.js
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
    $ screen -S statsd
    $ node stats.js alignak.js
    # And leave the screen...
    $ Ctrl+AD

    # Test StatsD
    $ ll /var/lib/graphite/whisper/alignak-statsd/statsd/
        total 84
        drwxr-xr-x 6 _graphite _graphite  4096 févr.  2 20:11 ./
        drwxr-xr-x 3 _graphite _graphite  4096 févr.  2 20:11 ../
        drwxr-xr-x 2 _graphite _graphite  4096 févr.  2 20:11 bad_lines_seen/
        drwxr-xr-x 2 _graphite _graphite  4096 févr.  2 20:11 graphiteStats/
        drwxr-xr-x 2 _graphite _graphite  4096 févr.  2 20:11 metrics_received/
        -rw-r--r-- 1 _graphite _graphite 17308 févr.  2 20:12 numStats.wsp
        drwxr-xr-x 2 _graphite _graphite  4096 févr.  2 20:11 packets_received/
        -rw-r--r-- 1 _graphite _graphite 17308 févr.  2 20:12 processing_time.wsp
        -rw-r--r-- 1 _graphite _graphite 17308 févr.  2 20:12 timestamp_lag.wsp


As of now you have a running StatsD daemon that will collect the Alignak internal metrics to feed Graphite.

Graphite Carbon
~~~~~~~~~~~~~~~
::

    $ sudo su

    $ apt-get update

    # Set TZ as UTC
    $ dpkg-reconfigure tzdata
    => UTC

    # Install Carbon
    $ apt-get install graphite-carbon

    # Configure Carbon
    $ vi /etc/default/graphite-carbon
    # Enable carbon service on boot
    => CARBON_CACHE_ENABLED=true

    # Configuration file
    $ vi /etc/carbon/carbon.conf
    # Enable log rotation
    => ENABLE_LOGROTATION = True

    # Aggregation configuration (default is suitable...)
    $ cp /usr/share/doc/graphite-carbon/examples/storage-aggregation.conf.example /etc/carbon/storage-aggregation.conf

    # Start the metrics collector service (Carbon)
    $ service carbon-cache start

    # Monitor activity
    $ tail -f /var/log/carbon/console.log

    # Test carbon (send a metric test.count)
    $ echo "test.count 4 `date +%s`" | nc -q0 127.0.0.1 2003
    $ ls /var/lib/graphite/whisper
    => test/count.wsp

Graphite API
~~~~~~~~~~~~
No need for the Graphite Web application, we will use Grafana ;)

::

    $ sudo su

    # Install Graphite-API
    ##### $ apt-get install graphite-api; do not seem to survive a system restart :)
    $ wget https://github.com/brutasse/graphite-api/releases/download/1.1.2/graphite-api_1.1.2-1447943657-ubuntu14.04_amd64.deb
    $ dpkg -i

    # Install Nginx / uWsgi
    $ apt-get install nginx uwsgi uwsgi-plugin-python

    # Configure uWsgi
    $ vi /etc/uwsgi/apps-available/graphite-api.ini
        [uwsgi]
        processes = 2
        socket = localhost:8080
        plugins = python27
        module = graphite_api.app:app
        buffer = 65536

    $ ln -s /etc/uwsgi/apps-available/graphite-api.ini /etc/uwsgi/apps-enabled
    $ service uwsgi restart

    # Configure nginx
    $ vi /etc/nginx/sites-available/graphite.conf
        server {
            listen 80;

            location / {
                include uwsgi_params;
                uwsgi_pass localhost:8080;
            }
        }

    $ ln -s /etc/nginx/sites-available/graphite.conf /etc/nginx/sites-enabled
    $ service nginx restart

StatsD
~~~~~~
::

    To be completed !


Grafana
~~~~~~~
::

    # Install Grafana (Version 4 only supported by the Alignak backend!)
    wget https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb
    apt-get install -y adduser libfontconfig
    dpkg -i grafana_3.1.1-1470047149_amd64.deb

    # Configure Grafana (not necessary...)
    $ vi /etc/grafana/grafana.ini

    $ service grafana-server start

    # Open your web browser on http://127.0.0.1:3000