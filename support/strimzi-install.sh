export STRIMZI_HOME=/home/gnunn/Development/kafka/strimzi-kafka-operator

oc new-project sko --display-name="Seat Registration"

# For 0.7..x release
sed -i 's/namespace: .*/namespace: sko/' ${STRIMZI_HOME}/examples/install/cluster-operator/*RoleBinding*.yaml

# For 0.6.x release
# sed -i 's/namespace: .*/namespace: sko/' ${STRIMZI_HOME}/examples/install/cluster-operator/*ClusterRoleBinding*.yaml

oc apply -f ${STRIMZI_HOME}/examples/install/cluster-operator -n sko
# oc apply -f ${STRIMZI_HOME}/examples/templates/cluster-operator -n sko
# oc process -f ${STRIMZI_HOME}/examples/templates/cluster-operator/persistent-template.yaml -p CLUSTER_NAME=sko -p ZOOKEEPER_NODE_COUNT=1 -p KAFKA_NODE_COUNT=3 | oc create -f -

oc apply -f sko-kafka-persistent.yaml
