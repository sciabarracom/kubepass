#!/bin/bash

CMD="${1:-help}"
NUM="${2:-3}"
MEM="${3:-2}"
DISK="${4:-15}"
VCPU="${5:-1}"

YAML="$(dirname $0)/kubepass.yaml"
MULTIPASS=multipass

if ! "$MULTIPASS" -h >/dev/null 
then echo "Install multipass 0.7.1, please."
     echo "https://github.com/CanonicalLtd/multipass/releases/tag/v0.7.1"
     exit 1
fi

build() {
   COUNT="$1"
   ARGS_MASTER="$2"
   ARGS_WORKERS="$3"
   if ! test -f $YAML 
   then echo "no $YAML" ; exit 1 
   fi 
   "$MULTIPASS" launch -n kube-master $ARGS_MASTER --cloud-init $YAML
   for (( I=1 ; I<= $COUNT; I++))
   do "$MULTIPASS" launch -n "kube-node$I" $ARGS_WORKERS --cloud-init $YAML
   done
   "$MULTIPASS" exec kube-master -- cloud-init status --wait 
   "$MULTIPASS" exec kube-master -- wait-ready "$(expr "$COUNT" + 1)"
   echo "Ready!"
}

destroy() {
   COUNT="$1"
   echo "Deleting kube-master"
   "$MULTIPASS" -v delete kube-master
   for (( I=1 ; I<= $COUNT; I++))
   do  echo "Deleting kube-worker$I"
       "$MULTIPASS" delete "kube-node$I"
   done
   "$MULTIPASS" -v purge
}

are_you_sure() {
   read -p "Are you sure? " -n 1 -r
   echo ""
   if [[ $REPLY =~ ^[Yy]$ ]]
   then return
   fi
   echo "Aborting..."
   exit 1
}

case "$CMD" in
 create) 
   echo "Creating Kubernetes Cluster: master ${MEM}G 2cpu, $NUM workers with ${VCPU} cpu, ${MEM}G mem, ${DISK}G disk"
   build $NUM "-c 2 -d ${DISK}G -m ${MEM}G" "-c $VCPU -d ${DISK}G -m ${MEM}G"
 ;;
 destroy) 
   echo "Destroying the cluster"
   are_you_sure
   destroy $NUM
 ;;
 config)
    if test -f ~/.kube/config
    then echo "Overwriting ~/.kube/config"
         are_you_sure
    fi
    "$MULTIPASS" exec kube-master -- sudo cat /etc/kubernetes/admin.conf >~/.kube/config
 ;;
 nodes) 
   "$MULTIPASS" exec kube-master -- sudo kubectl get nodes 
 ;;
 *)
    echo "usage: (create|config|destroy) [#workers] [mem] [disk] [#vcpu]"
    echo "mem and disk are in giga, workers and vcpu a count"
    echo "defaults: 3 workers with 1vcpu with 2G mem 15G disk" 
  ;;
esac
