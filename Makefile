cluster: index.html
	bash cluster.sh index.html

small: index.html
	bash small.sh index.html

large: index.html
	bash large.sh index.html

index.html: cloud-init.yaml cloud-init.shar
	cat cloud-init.yaml >$@
	cat cloud-init.shar | sed -e 's/^/        /' >>$@

cloud-init.shar: master.sh worker.sh 
	shar $^ >>$@

destroy:
	-rm cloud-init.shar
	-multipass delete kube-master
	-multipass delete kube-worker1
	-multipass delete kube-worker2
	-multipass delete kube-worker3
	-multipass purge

enter:
	@if test -z "$(N)" ;\
	then multipass shell kube-master ;\
	else multipass shell kube-worker$(N) ; fi

state:
	multipass exec -- kube-master bash -c "cloud-init status --wait && sudo watch kubectl get nodes"

.PHONY: cluster small large destroy enter state

