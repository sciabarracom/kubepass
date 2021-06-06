+++
author = "Michele Sciabarrà"
title = "Create a development Kubernetes cluster with multipass and microk8s"
date = "2021-06-06"
description = "You can easily build a development Kubernetes Cluster leveraging multiplass and microk8s"
tags = [ "Linkedin" ]
draft = false
+++

# TL;DR

bash <(curl bit.ly/kubepass-small)

I want to deploy OpenWhisk on a development cluster

URL=https://raw.githubusercontent.com/openwhisk-blog/create-cluster-kubepass/main/cloud-init-master.yaml

curl -sL $URL | multipass launch -c2 -m2G -n kube0 --cloud-init -


curl $URL

sudo bash


