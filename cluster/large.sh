#!/bin/sh
YAML=${1:-cloud-init.yaml}
if ! test -f $YAML
then curl -s http://kubepass.sciabarra.com >$YAML
fi
multipass launch -n kube-master -c 2 -m 4G -d 25G --cloud-init $YAML
multipass launch -n kube-worker1 -c 2-m 4G -d 25G --cloud-init $YAML
multipass launch -n kube-worker2 -c 2 -m 4G -d 25G --cloud-init $YAML
multipass launch -n kube-worker3 -c 2 -m 4G -d 25G --cloud-init $YAML
multipass exec -- kube-master bash -c "cloud-init status --wait && sudo watch kubectl get nodes"

