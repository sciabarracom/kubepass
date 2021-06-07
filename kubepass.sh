#!/bin/bash

P=${P:=kube}
N=${N:=2}
C=${C:=2}
D=${D:=10}
M=${M:=2}

if ! which multipass
then echo "Please install multipass from https://multipass.run/"
     exit 1
fi

echo "Instance Count  : $N"
echo "Instance Prefix : $P"
echo "CPU/instance    : $C"
echo "Memory/instance : $M"g
echo "Disk/instance   : $D"g

for ((I=0 ; I < $N ; I++))
do
  multipass launch -n"$P$I" -c"$C" -m"$M"g -d"$D"g --cloud-init kubepass.yaml
  multipass exec "$P$I" -- sudo cloud-init status --wait
done

multipass transfer "${P}0:/etc/kubeconfig" "kubeconfig"
kubectl --kubeconfig=kubeconfig get nodes
echo "Your cluster is ready, configuration saved as ./kubeconfig"