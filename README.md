# Kubepass

Tired of minikube? Needing a _real_ Kubernetes cluster when doing your development work? Use *kubepass*. 

## What is this?

It is a `cloud-init` script to setup a real Kubernetes *cluster* for development, using either OSX, Linux or Windows, using `multipass`.

### What is multipass?

It is an awesome utility from Canonical able to setup a virtual machine from a command line. It works on Linux, MacOS and Windows. It uses native virtual machine support provided by the various operating system (KVM on Linux, bhyve on MacOS, HyperV on Windows).

### And what is cloud-init?

It is an initialization format for "cloud" images. It is used by multipass, so I leveraged it to setup a Kubernetes cluster.

### Mmmm, and what is Kubernetes?

Oh, well... check [https://kubernetes.io](here). 

# Prererequisites

You need a recent version of Windows 10 (at least build 1083), Linux or MacOS that supports multipass (it requires virtual machine support).

Before starting, install [https://github.com/CanonicalLtd/multipass/releases/tag/v0.7.0](multipass). 

Then download `kubepass.yaml`:

- On Linux shell/MacOS terminal/Windows Command: `curl -Ls kubepass.sciabarra.com >kubepass.yaml`

# Building your cluster

You can build your cluster creating a master and multiple workers. 

The master must be named `kube-master`, and needs at least 2Gb of memory, 2 Vcpu and 10gb of disk space. Generally you need also at lest two workers with 1Gb memory each. To setup such a cluster (you need at least 8Gb of physical memory):

```
multipass launch -n kube-master -m2g -c2 -d10g --cloud-init kubepass.yaml
multipass launch -m1g --cloud-init kubepass.yaml
multipass launch -m1g --cloud-init kubepass.yaml
```

Of course you can tune the memory (`-m`) the number of CPU (`-c`) and the disk size (`-d`) as you prefer. You can also give a name (`-n`) to each virtual machine. The only requirement for namese is that the master is called `kube-master`.

Once you launched the VMs you can wait for the cluster to bee ready with:

```
multipass exec kube-master -- cloud-init status --wait
multipass exec kube-master -- wait-ready 3
```

Replace `3` with the actual number of nodes in the cluster.

## Cleanup

When you are  done, remove the entire cluster with:

```
multipass delete --all
multipass purge
```

Warning! This removes all the virtual machines.
If you want to be more selective, list the virtual machines with `multipass list` and then delete them individually.
