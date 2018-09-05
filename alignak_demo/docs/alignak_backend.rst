Using Alignak backend
#####################

*REST API and database backend for Alignak*

Alignak-backend is a database backend for Alignak It may be used:

* as a configuration repository for the monitored objects

* as a retention data storage

* as a live status manager

* as an interface for the timeseries databases (Graphite, InfluxDB, ...)

Installing
==========
::

   # Alignak backend
   sudo pip install alignak-backend
   # To allow alignak user to view the log files
   sudo chown -R alignak:alignak /usr/local/var/log/alignak-backend/

**Note** that you will need to have a running MongoDB server. See the `Alignak backend installation procedure <http://alignak-backend.readthedocs.io/en/develop/install.html>`_ if you need to set one up and running.

An excerpt for installing MongoDB on an Ubuntu Xenial::

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org
    sudo systemctl enable mongod.service
    sudo systemctl start mongod.service


Configuring MongoDB is not mandatory because the Alignak backend do not require any authenticated connection to the database. But if you wish a more secure DB access with user authentication, you must configure MongoDB::

   mongo

   # Not necessary, but interesting... with the most recent 4.0 version, a new monitoring tool is available;)
   > db.enableFreeMonitoring()
   {
      "state" : "enabled",
      "message" : "To see your monitoring data, navigate to the unique URL below. Anyone you share the URL with will also be able to view this page. You can disable monitoring at any time by running db.disableFreeMonitoring().",
      "url" : "https://cloud.mongodb.com/freemonitoring/cluster/KAI3EQPMSZHNGDELYLDNA6QVCPZ5IK6B",
      "userReminder" : "",
      "ok" : 1
   }

   # Create an admin user for the server
   > use admin
   > db.createUser(
      {
         user: "alignak",
         pwd: "alignak",
         roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
      }
   )

   Successfully added user: {
      "user" : "alignak",
      "roles" : [
         {
            "role" : "userAdminAnyDatabase",
            "db" : "admin"
         }
      ]
   }

   # Exit and restart the server
   Ctrl+C

   # Configure mongo in authorization mode
   sudo vi /etc/mongod.conf
      security:
         authorization: enabled

   # Restart mongo
   sudo systemctl restart mongod.service
   # As of now, you will need to authenticate for any operation on the MongoDB databases

   mongo -u alignak -p alignak
   > show dbs
   admin   0.000GB
   config  0.000GB
   local   0.000GB


   > use alignak
   > db.createUser(
      {
         user: "alignak",
         pwd: "alignak",
         roles: [ "readWrite", "dbAdmin" ]
      }
   )

   Successfully added user: { "user" : "alignak", "roles" : [ "readWrite", "dbAdmin" ] }

   > db.test.save( { test: "test" } )
   # This will create atest collection in the database, which will create the DB in mongo server

   > show dbs
   admin    0.000GB
   alignak  0.001GB
   config   0.000GB
   local    0.000GB


Configure, run and feed Alignak backend
=======================================

It is not necessary to change anything in the Alignak backend configuration file except if your MongoDB installation is not a local database configured by default. Else, open the */usr/local/share/alignak-backend/etc/settings.json* configuration file to set-up the parameters according to your configuration.

Start / stop the backend
------------------------

Run the Alignak backend according to the documentation. We are assuming a system service installation::

   sudo service alignak-backend start

   # Check running processes
   ps -aux | grep uwsgi
      alignak 10291  0.0  0.5 322784 83484  -  SJ   16:21   0:01.65 /usr/local/bin/uwsgi --master --enable-threads --daemonize /dev/null --wsgi-file /usr/local/share/alignak-bac
      alignak 10345  0.0  0.5 300740 81268  -  IJ   16:21   0:00.00 /usr/local/bin/uwsgi --master --enable-threads --daemonize /dev/null --wsgi-file /usr/local/share/alignak-bac
      alignak 10346  0.0  0.5 300740 81264  -  IJ   16:21   0:00.00 /usr/local/bin/uwsgi --master --enable-threads --daemonize /dev/null --wsgi-file /usr/local/share/alignak-bac
      alignak 10347  0.0  0.5 300740 81268  -  IJ   16:21   0:00.00 /usr/local/bin/uwsgi --master --enable-threads --daemonize /dev/null --wsgi-file /usr/local/share/alignak-bac
      alignak 10348  0.0  0.5 300740 81268  -  IJ   16:21   0:00.00 /usr/local/bin/uwsgi --master --enable-threads --daemonize /dev/null --wsgi-file /usr/local/share/alignak-bac
      alignak 10349  0.0  0.5 304836 84904  -  IJ   16:21   0:00.00 /usr/local/bin/uwsgi --master --enable-threads --daemonize /dev/null --wsgi-file /usr/local/share/alignak-bac

   sudo service alignak-backend stop


Feed the backend
----------------

Alignak ships a flat-file configuration importation script to help feedinf Nagios legacy flat-files configuration into the Alignak backend. This script is used to parse, check and import a Nagios-like configuration into the Alignak backend.

**Note** that it is not mandatory to install and use this script because the Alignak WebUI allows to create all the monitored objects configuration from scratch :)

For this demo, we will install and use the `alignak-backend-import` script. So let's install it::

    # Alignak backend importation script
    sudo pip install alignak-backend-import



Run the Alignak backend import script to push the demo configuration into the backend:::

   # Import the demo configuration into the backend
   cd ~/repos/alignak
   alignak-backend-import -d ./etc/alignak.cfg
      ...
      ...
      ...
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      alignak-backend-import, inserted elements:
       - 10 command(s)
       - 37 host(s)
       - 8 host_template(s)
       - no hostdependency(s)
       - no hostescalation(s)
       - 2 hostgroup(s)
       - 1 realm(s)
       - 40 service(s)
       - 37 service_template(s)
       - no servicedependency(s)
       - no serviceescalation(s)
       - 1 servicegroup(s)
       - 4 timeperiod(s)
       - 3 user(s)
       - 1 user_template(s)
       - 2 usergroup(s)
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      Global configuration import duration: 8.65677189827

**Note**: *there are other solutions to feed the Alignak backend but we choose to show how to get an existing configuration imported in the Alignak backend to migrate from an existing Nagios/Shinken to Alignak.*

Once imported, you can check that the configuration is correctly parsed by Alignak::

   # Check Alignak demo configuration (from the git repo)
   alignak-arbiter -V -a ~/repos/alignak-demo/alignak_demo/etc/alignak.cfg

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


