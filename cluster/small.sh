#!/bin/sh
YAML=${1:-cloud-init.yaml}
if ! test -f $YAML
then curl -s http://kubepass.sciabarra.com >$YAML
fi
multipass launch -n kube-master -c 2 -m 2G -d 10G --cloud-init $YAML
multipass launch -n kube-worker1 -m 1G -d 10G --cloud-init $YAML
multipass launch -n kube-worker2 -m 1G -d 10G --cloud-init $YAML
