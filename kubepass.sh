#!/bin/bash
# <script>location.href='https://github.com/sciabarracom/kubepass'</script>
YAML="$(dirname $0)"/cloud-init.yaml
case "$1" in
destroy) echo "Destroying the cluster"
  read -p "Are you sure? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
   echo "
   multipass -v delete kube-master
   multipass -v delete kube-worker1
   multipass -v delete kube-worker2
   multipass -v delete kube-worker3
   multipass -v purge
  fi
;;
state) 
   shift
   multipass exec kube-master -- sudo kubectl get nodes "$@"
;;
huge) echo "Creating Huge Kubernetes Cluster: master 4G, 3 workers 4G, disk 25G"
   test -f $YAML || curl -Ls http://kubepass.sciabarra.com >$YAML
   multipass launch -n kube-master  -c 2 -m 4G -d 25G --cloud-init $YAML
   multipass launch -n kube-worker1 -c 2 -m 4G -d 25G --cloud-init $YAML
   multipass launch -n kube-worker2 -c 2 -m 4G -d 25G --cloud-init $YAML
   multipass launch -n kube-worker3 -c 2 -m 4G -d 25G --cloud-init $YAML
   multipass exec kube-master -- cloud-init status --wait 
;;
large) echo "Creating Large Kubernetes Cluster: master 4G, 3 workers 2G, disk 15G"
   test -f $YAML || curl -Ls http://kubepass.sciabarra.com >$YAML
   multipass launch -n kube-master  -c 2 -m 4G -d 15G --cloud-init $YAML
   multipass launch -n kube-worker1 -c 2 -m 2G -d 15G --cloud-init $YAML
   multipass launch -n kube-worker2 -c 2 -m 2G -d 15G --cloud-init $YAML
   multipass launch -n kube-worker3 -c 2 -m 2G -d 15G --cloud-init $YAML
   multipass exec kube-master -- cloud-init status --wait 
;;
*) echo "Creating Small Kubernetes Cluster: master 2G, 3 workers 1G, disk 10G"
   test -f $YAML || curl -Ls http://kubepass.sciabarra.com >$YAML
   multipass launch -n kube-master  -c 2 -m 2G -d 10G --cloud-init $YAML
   multipass launch -n kube-worker1 -c 2 -m 1G -d 10G --cloud-init $YAML
   multipass launch -n kube-worker2 -c 2 -m 1G -d 10G --cloud-init $YAML
   multipass launch -n kube-worker3 -c 2 -m 1G -d 10G --cloud-init $YAML
   multipass exec kube-master -- cloud-init status --wait 
;;
esac
