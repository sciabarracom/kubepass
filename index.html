#!/bin/bash
# <script>location.href='https://github.com/sciabarracom/kubepass'</script>

CMD="${1:-small}"
NUM="${2:-3}"

YAML=~/.kubepass.yaml
WINMULTIPASS="/c/Program Files/Multipass"

MULTIPASS=multipass
if test -d "$WINMULTIPASS"
then PATH="$WINMULTIPASS/bin:$PATH"
     MULTIPASS=multipass.exe
fi
if ! "$MULTIPASS" -h >/dev/null 
then echo "Install multipass 0.6.1, please."
     echo "https://github.com/CanonicalLtd/multipass/releases/tag/v0.6.1"
     exit 1
fi

build() {
   COUNT="$1"
   ARGS_MASTER="$2"
   ARGS_WORKERS="$3"
   test -f $YAML || curl -Ls https://kubepass.sciabarra.com/kubepass.yaml >$YAML
   "$MULTIPASS" launch -n kube-master $ARGS_MASTER --cloud-init $YAML
   for (( I=1 ; I<= $COUNT; I++))
   do "$MULTIPASS" launch -n "kube-worker$I" $ARGS_WORKERS --cloud-init $YAML
   done
   "$MULTIPASS" exec kube-master -- cloud-init status --wait 
}

destroy() {
   COUNT="$1"
   echo "Deleting kube-master"
   "$MULTIPASS" -v delete kube-master
   for (( I=1 ; I<= $COUNT; I++))
   do  echo "Deleting kube-worker$I"
       "$MULTIPASS" delete "kube-worker$I"
   done
   "$MULTIPASS" -v purge
}

case "$CMD" in
 destroy) 
   echo "Destroying the cluster"
   read -p "Are you sure? " -n 1 -r
   echo ""
   if [[ $REPLY =~ ^[Yy]$ ]]
   then destroy $NUM
   fi
 ;;
 nodes) 
   "$MULTIPASS" exec kube-master -- sudo kubectl get nodes 
 ;;
 huge) 
   echo "Creating Huge Kubernetes Cluster: master 4G, 3 workers 4G, disk 25G"
   build $NUM "-c 2 -d 25G -m 4G" "-c 2 -d 25G -m 4G"
 ;;
 large) 
   echo "Creating Large Kubernetes Cluster: master 4G, 3 workers 2G, disk 15G"
   build $NUM "-c 2 -d 25G -m 4G" "-c 2 -d 25G -m 4G"
 ;;
 small) 
   echo "Creating Small Kubernetes Cluster: master 2G, 3 workers 1G, disk 10G"
   build $NUM "-c 2 -d 10G -m 2G" "-c 1 -d 10G -m 1G"
 ;;
 *)
    echo "usage: (small|large|huge|destroy) [#workers]"
 ;;
esac
