#!/bin/sh
MyHOSTNAME="localhost";
/etc/init.d/mongodb start

# Drop all databases existing in the MongoDB server
for i in $(mongo --quiet --host $MyHOSTNAME --eval "db.getMongo().getDBNames()" | tr "," " ");
    do mongo $i --host $MyHOSTNAME --eval "db.dropDatabase()";
done
