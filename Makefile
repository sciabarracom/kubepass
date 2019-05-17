S ?= index.html

ifndef N
  HOST=kube-master
else
 HOST=kube-worker$(N)
endif

index.html: cloud-init.yaml cloud-init.shar
	cat cloud-init.yaml >$@
	cat cloud-init.shar | sed -e 's/^/        /' >>$@

cluster: index.html
	bash cluster/$(S) index.html

cloud-init.shar: master.sh worker.sh 
	shar $^ >>$@

destroy:
	-rm cloud-init.shar
	-multipass delete kube-master
	-multipass delete kube-worker1
	-multipass delete kube-worker2
	-multipass delete kube-worker3
	-multipass purge

shell:
	multipass shell $(HOST)

cloud-log:
	multipass exec $(HOST) tail -f /var/log/cloud-init-output.log

.PHONY: cluster small large destroy enter state

