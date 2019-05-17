#minishift config set memory 8384
#minishift config set cpus 4
#minishift config set disk-size 30g

#oc login -u system:admin

HOST_ROUTE=$1

export SOURCE_REPO=https://github.com/masauve/sko2018

if [ -z "$HOST_ROUTE" ]
then
      echo "HOST_ROUTE is empty, please enter your OpenShift Host route, ie, > setup.sh apps.sko18.opentlc.com  or > setup.sh 192.168.99.100.nip.io"
			exit
fi

rm -f configmap-gen.json
rm -f all.html

while read a ;
	do
		echo ${a//TOBEREPLACED/$HOST_ROUTE} ;
	done < configmap.json > configmap-gen.json ;

echo set all UI route listening to HOST $HOST_ROUTE

while read a ;
	do
		echo ${a//TOBEREPLACED/$HOST_ROUTE} ;
	done < all-template.html > all.html ;

oc project openshift
oc create -f https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-000085/fis-image-streams.json -n openshift
#oc create -f https://raw.githubusercontent.com/strimzi/strimzi/0.1.0/kafka-inmemory/resources/openshift-template.yaml -n openshift

# oc delete template nodejs-example -n openshift
oc create -f nodejs.json

############################################################################################

#oc login -u developer

echo "Create new projects"
#oc new-project sko

oc project sko

#echo "Start up AMQ Streaming"
#oc new-app strimzi


#DATABSE
##################################################################################################################################
echo "Start up MySQL for database access"
oc create -f mysql-ephemeral-template.json
oc new-app --template=mysql-ephemeral --param=MYSQL_PASSWORD=password --param=MYSQL_USER=dbuser --param=MYSQL_DATABASE=sampledb

echo "Setup mysqlDB"

#Wait for mysqldb constainer to startup
inputchk=`oc get pod | grep -v 'mysql-1-deploy' | grep 'mysql-1' | grep 'Running'`
while [ -z "$inputchk" ]
do
	#do nothing keep loop until mysql is up and running
	sleep 5s
	echo .
	inputchk=`oc get pod | grep -v 'mysql-1-deploy' | grep 'mysql-1' | grep 'Running'`
done

mysqlpod=`echo $inputchk | awk '{split($0,a," "); print a[1]}'`;

echo $mysqlpod

echo "Waiting for mysqldb to startup -- don't worry if you see error"
mysqlconnected=`oc exec $mysqlpod -- bash -c "mysql --user=dbuser --password=password sampledb -e 'select 1'"`

while [ -z "$mysqlconnected" ]
do
	#do nothing keep loop until mysql is up and running
	sleep 5s
	echo $mysqlconnected
	mysqlconnected=`oc exec $mysqlpod -- bash -c "mysql --user=dbuser --password=password sampledb -e 'select 1'"`
done

#Upload schema file
oc rsync db-mysql $mysqlpod:/var/lib/mysql/data

#Insert table into mysql
oc exec $mysqlpod -- bash -c "mysql --user=dbuser --password=password sampledb < /var/lib/mysql/data/db-mysql/schema.sql"



echo "Start up POSTGRESQL for database access"
oc create -f postgresql-ephemeral-template.json
oc new-app --template=postgresql-ephemeral --param=POSTGRESQL_USER=dbuser --param=POSTGRESQL_PASSWORD=password --param=POSTGRESQL_DATABASE=sampledb



echo "Setup postgresqkDB"
inputchk=`oc get pod | grep -v 'postgresql-1-deploy' | grep 'postgresql-1' | grep 'Running'`
while [ -z "$inputchk" ]
do
	#do nothing keep loop until mysql is up and running
	sleep 5s
	echo .
	inputchk=`oc get pod | grep -v 'postgresql-1-deploy' | grep 'postgresql-1' | grep 'Running'`
done

postgresqlpod=`echo $inputchk | awk '{split($0,a," "); print a[1]}'`;

echo $postgresqlpod

echo "Waiting for postgresql to startup -- don't worry if you see error"
postgresqlconnected=`oc exec $postgresqlpod -- bash -c "psql -U dbuser -q -d sampledb -c 'SELECT 1'"`

while [ -z "$postgresqlconnected" ]
do
	#do nothing keep loop until mysql is up and running
	sleep 5s
	echo $postgresqlconnected
	postgresqlconnected=`oc exec $postgresqlpod -- bash -c "psql -U dbuser -q -d sampledb -c 'SELECT 1'"`
done

#Upload schema file
oc rsync db-postgresql $postgresqlpod:/var/lib/pgsql/data/userdata
#Insert table into postgresql
oc exec $postgresqlpod -- bash -c "psql -U dbuser -d sampledb -a -f /var/lib/pgsql/data/userdata/db-postgresql/schema.sql"

#####################################################################################################################################


echo "Set up RouteConfigMap"
oc create -f configmap-gen.json

echo "Set up Nodejs template"
oc create -f nodejs.json


#Create Transform Camel
echo "Create Transform Camel"
oc create -f transform-camel.yml
oc new-app transform-camel --param=GIT_REPO=${SOURCE_REPO}

############################################################################################

#SEAT Listener
echo "Install SEAT Listener "
oc create -f seat-ui-listener.yml
oc new-app seat-ui-listener --param=GIT_REPO=${SOURCE_REPO}

#SEAT Reader
echo "Install SEAT Reader "
oc create -f seat-ui-reader.yml
oc new-app seat-ui-reader --param=GIT_REPO=${SOURCE_REPO}

# SEAT UI
echo "Install SEAT UI "
oc new-app --template=nodejs-ui --param=NAME=seat-ui --param=SOURCE_REPOSITORY_URL=${SOURCE_REPO} --param=CONTEXT_DIR=seat-ui --param=SOURCE_REPOSITORY_REF=master --param=UI_NAME=seat-ui


############################################################################################

echo "Install Registration Form "
#Registration Form
oc create -f registration-ui.json
oc new-app fuse-eap --param=SOURCE_REPOSITORY_URL=${SOURCE_REPO}

echo "Install Registration Monitor UI "
oc new-app --template=nodejs-ui --param=NAME=registration-live-ui --param=SOURCE_REPOSITORY_URL=${SOURCE_REPO} --param=CONTEXT_DIR=registration-live-ui --param=SOURCE_REPOSITORY_REF=master --param=UI_NAME=registration-live-ui

#Registration Command Center
echo "Install Registration Command Center "
oc create -f registration-command.yml
oc new-app registration-command --param=GIT_REPO=${SOURCE_REPO}


#undertow does not expose 8081 health
#oc set probe dc/registration-command --readiness --initial-delay-seconds=30 --period-seconds=30
#oc set probe dc/registration-command --liveness --initial-delay-seconds=360 --period-seconds=30
oc set probe dc/registration-command  --remove --readiness --liveness

############################################################################################
#Analytic
echo "Install Analytic Listener"
oc create -f analytic-listener.yml
oc new-app analytic-listener --param=GIT_REPO=${SOURCE_REPO}

#undertow does not expose 8081 health
#oc set probe dc/analytic-listener --readiness --initial-delay-seconds=30 --period-seconds=30
#oc set probe dc/analytic-listener --liveness --initial-delay-seconds=360 --period-seconds=30
oc set probe dc/analytic-listener  --remove --readiness --liveness

echo "Install Analytic UI"
oc new-app --template=nodejs-ui --param=NAME=analytic-ui --param=SOURCE_REPOSITORY_URL=${SOURCE_REPO} --param=CONTEXT_DIR=analytic-ui --param=SOURCE_REPOSITORY_REF=master --param=UI_NAME=analytic-ui
############################################################################################

#Simulator
echo "Install Simulator"
oc create -f seat-reserve-simulator.yml
oc new-app seat-reserve-simulator --param=GIT_REPO=${SOURCE_REPO}

# Stop the simulator for now
oc scale dc seat-reserve-simulator --replicas=0
