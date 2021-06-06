if which multipass ; then
   multipass launch -nkube0 -c2 -m1g --cloud-init kubepass.yaml
   multipass launch -nkube1 -c2 -m1g --cloud-init kubepass.yaml
   multipass launch -nkube2 -c2 -m1g --cloud-init kubepass.yaml
else
  echo Please install multipass
fi 