cluster:
	bash cluster.sh index.html

small:
	bash small.sh index.html

large:
	bash large.sh index.html

index.html: cloud-init.yaml cloud-init.shar
	cat cloud-init.yaml >$@
	cat cloud-init.shar | sed -e 's/^/        /' >>$@

cloud-init.shar: $(shell ls *.sh)
	shar $^ >>$@

destroy:
	-rm index.html cloud-init.shar
	-multipass delete kube-master
	-multipass delete kube-worker1
	-multipass delete kube-worker2
	-multipass delete kube-worker3
	-multipass purge

enter:
	if test -z "$(N)" ;\
	then multipass shell kube-master ;\
	else multipass shell kube-worker$(N) ; fi

state:
	multipass kube-master sudo watch kubectl get nodes

.PHONY: cluster small large destroy enter state

