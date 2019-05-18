# Kubepass

Tired of minikube? Needing a _real_ Kubernetes cluster when doing your development work? Use *kubepass*. 

## What is this?

It is a set of scripts to setup a real Kubernetes *cluster* for development, using either OSX, Linux. I actually also works on Windows, although with a few hacks. Virtual machine provided courtesy of *multipass*.

Before starting, install [https://github.com/CanonicalLtd/multipass/releases/tag/v0.6.1](multipass). 

On windows you also need [https://docs.microsoft.com/en-us/windows/wsl/install-win10](bash).

Currently tested version:

- Multipass 0.6.1
- MacOS Mojave 10.14.4
- Ubuntu Linux 18.06
- Windows 10 with WSL

## Ok, I have multipass and Linux or OSX, now?

If you trust my scripts, you have at least 8GB of memory and 30GB of disk space, you can setup a small cluster (one master 2Gb and 3 workers 1GB each, disk 10G), just:

```
$ curl -Ls kubepass.sciabarra.com | bash
```

If you want more, and you have at least 16GB of memory and 60GB of disk space, you can setup a large cluster (1 Master 4gb, 3 workers 2GB each)

```
$ curl -Ls kubepass.sciabarra.com >kubepass.sh
$ bash kubepass.sh large
```

If you want even more and you have at least 32GB of memory and 100GB of disk space, you can setup a huge cluster with

```
$ curl -Ls kubepass.sciabarra.com/cluster >kubepass.sh
$ bash kubepass.sh huge
```

## Cleanup

Ok, I have done, how can I get rid of the cluster?

```
$ multipass delete --all
```

This will actually delete all the multipass virtual machines. If you have other vms and you only want to delete the vms

```
$ curl -Ls kubepass.sciabarra.com/cluster >kubepass.sh
$ bash kubepass.sh destroy
```

## I have Windows!

TODO!

