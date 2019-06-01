multipass delete --all
multipass purge
curl -Ls kubepass.sciabarra.com >/tmp/kubepass.yaml
multipass launch -n kube-master -c2 -d10g -m2g --cloud-init /tmp/kubepass.yaml
multipass launch -m1g -d10g --cloud-init /tmp/kubepass.yaml
multipass launch -m1g -d10g --cloud-init /tmp/kubepass.yaml
multipass exec kube-master -- cloud-init status --wait
multipass exec kube-master -- wait-ready 3
multipass exec kube-master sudo cat /etc/kubernetes/admin.conf >~/.kube/config

