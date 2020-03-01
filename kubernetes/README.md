## Before you begin

Make sure you have a Kubernetes cluster locally on your machine. The best option is to use Minikube. Make sure to follow [this documentation](https://kubernetes.io/docs/tasks/tools/install-minikube/)
from here on how to set up Minikube locally on your machine.

## Get ready for GitOps (a.k.a Pull Based Deployments)

We will use pull based deployments for which we need [Flux](https://github.com/fluxcd/flux) running on your Kubernetes cluster. If you are new to GitOps, familiarize yourself by reading through some documentation [here](gitops.tech)

Flux is a Kubernetes operator that can help you with pull based deployments. Have a look here to set-up [Flux](https://docs.fluxcd.io/en/latest/tutorials/get-started.html) on your cluster.
