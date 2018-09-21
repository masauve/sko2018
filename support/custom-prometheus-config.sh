# Applies custom prometheus config that adds support for LastProcessingTime
oc create configmap prometheus-config --from-file=prometheus-config.yml

declare -a arr=("registration-command" "transform-camel"  "seat-ui-listener" "seat-ui-reader" "analytic-listener")

for i in "${arr[@]}"
do
 oc volume dc/${i} --add --name=prometheus-config --type=configmap --configmap-name=prometheus-config --mount-path=/opt/prometheus/prometheus-config.yml --sub-path=prometheus-config.yml
done
