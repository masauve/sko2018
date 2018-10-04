oc delete ClusterRoleBinding strimzi-cluster-operator
oc delete ClusterRoleBinding strimzi-cluster-operator-entity-operator-delegation
oc delete ClusterRoleBinding strimzi-cluster-operator-kafka-broker-delegation
oc delete ClusterRoleBinding strimzi-cluster-operator-topic-operator-delegation

oc delete crd kafkaconnects.kafka.strimzi.io
oc delete crd kafkaconnects2is.kafka.strimzi.io
oc delete crd kafkas.kafka.strimzi.io
oc delete crd kafkatopics.kafka.strimzi.io
oc delete crd kafkausers.kafka.strimzi.io

