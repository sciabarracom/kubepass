#!/bin/bash
# <script>location.href='https://github.com/sciabarracom/kubepass'</script>

CMD="${1:-help}"
NUM="${2:-3}"

YAML="$(dirname $0)/kubepass.yaml"
MULTIPASS=multipass

WINMULTIPASS="/c/Program Files/Multipass"
if test -d "$WINMULTIPASS"
then PATH="$WINMULTIPASS/bin:$PATH"
     MULTIPASS=multipass.exe
fi
if ! "$MULTIPASS" -h >/dev/null 
then echo "Install multipass 0.7.0, please."
     echo "https://github.com/CanonicalLtd/multipass/releases/tag/v0.7.0"
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
 huge) 
   echo "Creating Huge Kubernetes Cluster: master 4G, 3 workers 4G, disk 25G"
   build $NUM "-c 2 -d 25G -m 4G" "-c 2 -d 25G -m 4G"
 ;;
 large) 
   echo "Creating Large Kubernetes Cluster: master 2G, 3 workers 2G, disk 15G"
   build $NUM "-c 2 -d 15G -m 2G" "-c 1 -d 15G -m 2G"
 ;;
 small) 
   echo "Creating Small Kubernetes Cluster: master 2G, 3 workers 1G, disk 10G"
   build $NUM "-c 2 -d 10G -m 2G" "-c 1 -d 10G -m 1G"
 ;;
 *)
    echo "usage: (small|large|huge|config|destroy) [#workers]"
 ;;
esac
