#!/bin/sh
YAML=${1:-cloud-init.yaml}
if ! test -f $YAML
then curl -s http://kubepass.sciabarra.com >$YAML
fi
multipass launch -n kube-master -c 2 -m 4G -d 15G --cloud-init $YAML
multipass launch -n kube-worker1 -m 2G -d 15G --cloud-init $YAML
multipass launch -n kube-worker2 -m 2G -d 15G --cloud-init $YAML
multipass launch -n kube-worker3 -m 2G -d 15G --cloud-init $YAML

