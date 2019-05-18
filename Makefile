S ?= index.html

ifndef N
  HOST=kube-master
else
 HOST=kube-worker$(N)
endif

all: index.html cloud-init.yaml

index.html: kubepass.sh
	cp -f kubepass.sh index.html

cloud-init.yaml: cloud-init-base.yaml cloud-init.shar
	cat cloud-init-base.yaml >$@
	cat cloud-init.shar | sed -e 's/^/        /' >>$@

cloud-init.shar: master-init worker-init install
	shar $^ >$@

status:
	multipass exec $(HOST) -- cloud-init status --wait
	multipass exec $(HOST) -- sudo watch kubectl get nodes 

shell:
	multipass shell $(HOST)

cloud-log:
	multipass exec $(HOST) -- tail -f /var/log/cloud-init-output.log

get-kube-config:
	multipass exec kube-master sudo cat /etc/kubernetes/admin.conf >~/.kube/config
	kubectl get nodes

.PHONY: cluster small large destroy enter state

