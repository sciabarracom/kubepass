+++
author = "Michele Sciabarrà"
title = "Create a development Kubernetes cluster with multipass and microk8s"
date = "2021-06-06"
description = "You can easily build a development Kubernetes Cluster leveraging multiplass and microk8s"
tags = [ "Linkedin" ]
draft = false
+++

Do you want a development *cluster* in your machine?  A real one, with multiple nodes, not just minikube. 

I need it routinely when I work with OpenWhisk. For this reason I built my solution, and I am sharing it here.

# TL;DR

If you want to deploy a small kubernetes cluter, with just 3 nodes 1gb each, first [install multipass](https://multipass.run/), then type:

```
bash <(curl bit.ly/kubepass-small)
```

Hint: 
- if you are on mac and you have `brew` installed, you can install multipass with `brew install multipass`
- if you are on Linux and you have `snap` installed, you can install multipass with `snap install multipass`

# I want to know more. What is this?

This script basically launches 3 virtual machines using `multipass` and initialized them with [cloud-init](https://cloudinit.readthedocs.io/en/latest/), installing [microk8s](https://microk8s.io/).

*Multipass* is a nice tool from Ubuntu that creates ubuntu based virtual machines everywhere. It is available for Mac OSX, Linux and Windows.

The images used can be initalized using *cloud-init*, that is the tool used nowadays to initialize cloud instances. We leverage that tool to install microk8s.

*Microk8s* is a Kubernetes distribution from Ubuntu also, that is very easy to install.

# How it works?

You need to download the `kubepass.yaml` with this command: `curl -sL bit.ly/kubepass >kubepass.yaml`.

Once you have it you can create a bunch of virtual machines. In an ideal world you could just pass the Yaml file to build the VMs. Unfortunately there is a catch.

First I need to distinguish the virtual machines, and I use for this purpose a number at the end of the name. So you have to name your virtual machines like `kube0`, `kube1`, `kube2` and so on. The first one needs to always end in `0`.

Furthermore you need at least 2 cpu instead of 1. So the absolute minimum to create a cluster is 

```
multipass launch -nk0 -c2 --cloud-init kubepass.yaml
multipass launch -nk1 -c2 --cloud-init kubepass.yaml
```

This will create a cluster with 2 nodes with 2 cpu.

I want to deploy OpenWhisk on a development cluster

URL=https://raw.githubusercontent.com/openwhisk-blog/create-cluster-kubepass/main/cloud-init-master.yaml

curl -sL $URL | multipass launch -c2 -m2G -n kube0 --cloud-init -

multipass launch -c2 -m2G -n kube0 --cloud-init cloud-init-master.yaml



curl $URL

sudo bash


