## Before you begin

Make sure you have a Kubernetes cluster locally on your machine. The best option is to use Minikube. Make sure to follow [this documentation](https://kubernetes.io/docs/tasks/tools/install-minikube/)
from here on how to set up Minikube locally on your machine.

## Build & compose the Kubernetes resources
Since our kubernetes resources are scattered across different files for better organization, we need a way to deploy them in an order and in many big projects this could get out of control. Fortunately, there is a project called [kustomization](https://github.com/kubernetes-sigs/kustomize) that you can use to compose the different resources into one big yml file that you can use to apply to your Kubernetes cluster.

Note: kubectl latest version contains kustomization, so no need of any additional installation!

So with this in mind, you should be able to compose the files using the following command (on the kubernetes folder of this project):

```
kubectl kustomize ./kubernetes > plant-simulator-k8s.yml
```

The result of the above command is a single yml file that contains all the necessary k8s resources in proper order for your Kubenetes cluster!

## Get ready for GitOps (a.k.a Pull Based Deployments)

We will use pull based deployments for which we need [Flux](https://github.com/fluxcd/flux) running on your Kubernetes cluster. If you are new to GitOps, familiarize yourself by reading through some documentation [here](gitops.tech)

Flux is a Kubernetes operator that can help you with pull based deployments. Have a look here to set-up [Flux](https://docs.fluxcd.io/en/latest/tutorials/get-started.html) on your cluster.

TODO: How to compose and build the files? As we want this to get execuited by flux when it connects and pulls the latest image!

Test Test
