#!/bin/bash
if ! test "$(hostname)" == "kube-master"
then echo "I am not the kube-master" ; exit 0
fi
echo "*** Kubernetes Pulling Images:"
kubeadm config images pull
echo "*** Initializing Kubernetes:"
if ! kubeadm init \
--apiserver-advertise-address "0.0.0.0" \
| tee /tmp/kubeadm.log
then exit 1
fi
echo "*** Installing Weave:"
export K8S_VERSION="$(kubectl version | base64 | tr -d '\n')"
export WEAVE_URL="https://cloud.weave.works/k8s/net?k8s-version=$K8S_VERSION"
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "$WEAVE_URL"
echo "*** Waiting for Kubernetes to get ready:"
STATE="NotReady"
while test "$STATE" != "Ready" ; do 
STATE=$(kubectl get node | tail -1 | awk '{print $2}')
echo -n "." ; sleep 1
done
echo ""
if grep "kubeadm join" /tmp/kubeadm.log >/dev/null
then apt-get install -y tftpd-hpa
     kubeadm token create --ttl 0 --print-join-command >/var/lib/tftpboot/kube-join.sh
     systemctl start tftpd-hpa
     echo "Created Token and Shared with Tftp"
else echo "No join command ready - something went wrong" ; exit 1
fi

