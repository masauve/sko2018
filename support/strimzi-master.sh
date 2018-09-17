export STRIMZI_HOME=/home/gnunn/Development/kafka/strimzi-kafka-operator

sed -i 's/namespace: .*/namespace: sko/' ${STRIMZI_HOME}/examples/install/cluster-operator/*RoleBinding*.yaml
oc apply -f ${STRIMZI_HOME}/examples/install/cluster-operator -n sko
oc apply -f ${STRIMZI_HOME}/examples/templates/cluster-operator -n sko
oc process -f ${STRIMZI_HOME}/examples/templates/cluster-operator/ephemeral-template.yaml -p CLUSTER_NAME=sko | oc create -f -
