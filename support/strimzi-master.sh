export STRIMZI_HOME=/home/gnunn/Development/kafka/strimzi-kafka-operator

oc new-project sko --display-name="Seat Registration"

sed -i 's/namespace: .*/namespace: sko/' ${STRIMZI_HOME}/examples/install/cluster-operator/*RoleBinding*.yaml
oc apply -f ${STRIMZI_HOME}/examples/install/cluster-operator -n sko
oc apply -f ${STRIMZI_HOME}/examples/templates/cluster-operator -n sko
oc process -f ${STRIMZI_HOME}/examples/templates/cluster-operator/ephemeral-template.yaml -p CLUSTER_NAME=sko -p ZOOKEEPER_NODE_COUNT=1 -p KAFKA_NODE_COUNT=1 | oc create -f -
