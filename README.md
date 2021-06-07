+++
author = "Michele Sciabarrà"
title = "Create a development Kubernetes cluster with multipass and microk8s"
date = "2021-06-06"
description = "You can easily build a development Kubernetes Cluster leveraging multiplass and microk8s"
tags = [ "Kubernetes" ]
draft = false
+++

Do you want to setup an actual kubernetes *cluster* in cloud machine?  Sure, you can use minikube for this purpose. However I prefer to build a cluster that is closer to the one I use in production. 

For this reason I built my solution for quickly deploying one, using `multipass`, `cloud-init` and `microk8s` and I am sharing it here.

# TL;DR

If you want to deploy a small kubernetes cluter, with just 2 nodes of 2gb each,  [install multipass](https://multipass.run/) clone this repo and run


```
bash kubepass.sh
```

At this point there will be also a `kubeconfig` file in your current directory. You need also need to install the `kubectl` command to access the cluster (see below). Once you got this, you can connect to the cluster with:

```
kubectl --kubeconfig=kubeconfig get nodes
```

Installation hints:
- if you are on mac and you have `brew` installed, you can install multipass and kubectl with `brew install multipass`.
- if you are on Linux and you have `snap` installed, you can install multipass with `snap install multipass kubectl --classic `

The script is actually customizable, as you can pass a few variables to change its behaviour.

- `N` is the number of instances, default 2
- `M` is the allocated memory per instance in giga, default 2
- `C` is the number of vcpu per instance, default 2
- `D` is the disk size in giga, default 10
- `P` is the prefix of virtual machine names, default `kube`

You can then change parameters, creating a cluster with 3 machines with 4G of memory and 20GB disk each with:

```
N=3 M=4 C=2 D=20 P=big bash kubepass.sh
```

# I want to know more. What is this?

This script basically launches 3 virtual machines using `multipass` and initialized them with [cloud-init](https://cloudinit.readthedocs.io/en/latest/), installing [microk8s](https://microk8s.io/).

*Multipass* is a nice tool from Ubuntu that creates virtual machines everywhere, using ubuntu-based operating system images. It is available for Mac OSX, Linux and Windows.

The virtual machine can be initalized using *cloud-init*, that is the same tool widely used to initialize cloud instances. We leverage that tool to install microk8s.

*Microk8s* is a Kubernetes distribution from Ubuntu also, that is very easy to install.

# How it works, step by step

If you do not trust an "unknown" script you can actually perform its work step by step. I do not repeat here how to install multipass and kubectl, I assume you did it.

Let's see how the script works. In an ideal world you could just pass the YAML file to build the VMs. Unfortunately there are a few catches.

First, I need to distinguish the virtual machines, assigning them an unique IP. For this purpose I assume there is a number at the end of the hostnames. So you have to name your virtual machines like `kube0` (with `-nkube0`), then `kube1`, `kube2` and so on . The first one must always end with `0`.

Furthermore, you need to assign at least 2 CPUs (with `-c2`) and 2 GB of memory (with `-m2g`) to each node, instead of 1 that is the default.  So the absolute minimum to create a cluster with 2 nodes is 

```
multipass launch -nkube0 -m2g -c2 --cloud-init kubepass.yaml
multipass launch -nkube1 -m2g -c2 --cloud-init kubepass.yaml 
``

Once you started all your VMs you have to retrieve the kubernetes configuration.
Luckily microk8s does it for you so all you need to do 

```
multipass transfer kube0:/etc/kubeconfig kubeconfig
kubectl --kubeconfig=kubeconfig get nodes
```

And you should see something like this:

```
NAME    STATUS   ROLES    AGE   VERSION
kube0   Ready    <none>   83m   v1.20.7-34+df7df22a741dbc
kube1   Ready    <none>   75m   v1.20.7-34+df7df22a741dbc
```

Your kubernetes cluster is ready!

When you are done you can destroy your cluster with `multipass remove --all -p`.

# Warning!

This is a development installation only of Kubernetes, and as such it is not designed to be secure nor reliable! Most notably, to avoiding the exchange of a generated token among nodes in order to join the cluster, the token is hardwired and pretty obvious. Furthermore, when you reboot your machine, IP may change and thus the cluster can break.
