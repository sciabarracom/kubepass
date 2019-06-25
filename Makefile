S ?= index.html

ifndef N
  HOST=kube-master
else
  HOST=kube-worker$(N)
endif

index.html: kubepass.yaml kubepass.shar
	cp kubepass.yaml index.html

kubepass.yaml: kubepass.shar
	cat cloud-init.yaml >$@
	cat kubepass.shar | sed -e 's/^/        /' >>$@

kubepass.shar: $(shell find  bin -type f)
	shar $^ >$@

clean:
	-rm index.html kubepass.yaml kubepass.shar
 
status:
	multipass exec $(HOST) -- cloud-init status --wait
	multipass exec $(HOST) -- sudo watch kubectl get nodes 

shell:
	multipass shell $(HOST)

cloud-log:
	multipass exec $(HOST) -- tail -f /var/log/cloud-init-output.log

kube-config:
	multipass exec kube-master sudo cat /etc/kubernetes/admin.conf >~/.kube/config
	kubectl get nodes

.PHONY: status shell cloud-log kube-config
