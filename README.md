### plant-simulator-deployment

This is the deployment / infrastructure project for the plant-simulator digital twin project that can be found [here](https://github.com/joesan/plant-simulator) in my repository. This project contains all it is necessary to run the [plant-simulator](https://github.com/joesan/plant-simulator) application in a kubernetes cluster in the [GitOps](gitops.tech) way! 

![GitOps Workflow](https://github.com/joesan/plant-simulator-deployment/blob/master/GitOps_Workflow.JPG)

From the image description (sorry for the free hand drawing), you could see that GitOps paves the way for some read CD right after a CI.

## Before you begin

Make sure you have a Kubernetes cluster locally on your machine. The best option is to use Minikube. Make sure to follow [this documentation](https://kubernetes.io/docs/tasks/tools/install-minikube/)
from here on how to set up Minikube locally on your machine.

After installation of Minikube using Homebrew on my Mac, here is a run of the minikube start command on my Mac

```
Joes-MacBook-Pro:~ joesan$ cls
Joes-MacBook-Pro:~ joesan$ minikube config set vm-driver virtualbox
⚠️  These changes will take effect upon a minikube delete and then a minikube start
Joes-MacBook-Pro:~ joesan$ minikube start --vm-driver=virtualbox
😄  minikube v1.7.3 on Darwin 10.15.1
✨  Using the virtualbox driver based on user configuration
🔥  Creating virtualbox VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.17.3 on Docker 19.03.6 ...
💾  Downloading kubeadm v1.17.3
💾  Downloading kubectl v1.17.3
💾  Downloading kubelet v1.17.3
🚀  Launching Kubernetes ...
🌟  Enabling addons: default-storageclass, storage-provisioner
⌛  Waiting for cluster to come online ...
🏄  Done! kubectl is now configured to use "minikube"
Joes-MacBook-Pro:~ joesan$
```

Now let us see what the kubectl get pods command brings up:

```
Joes-MacBook-Pro:deploy joesan$ kubectl get pods --all-namespaces
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-6955765f44-4n5wh           1/1     Running   0          62s
kube-system   coredns-6955765f44-fdmsn           1/1     Running   0          62s
kube-system   etcd-minikube                      1/1     Running   0          69s
kube-system   kube-apiserver-minikube            1/1     Running   0          69s
kube-system   kube-controller-manager-minikube   1/1     Running   0          69s
kube-system   kube-proxy-84lnn                   1/1     Running   0          62s
kube-system   kube-scheduler-minikube            1/1     Running   0          69s
kube-system   storage-provisioner                1/1     Running   0          69s
Joes-MacBook-Pro:deploy joesan$
```

As it can be seen that we have a bare bones kubernetes cluster from Minikube! Let us now proceed to set up Flux operator on this cluster which will do the GitOps for us!

## Get ready for GitOps (a.k.a Pull Based Deployments)

We will use pull based deployments for which we need [Flux](https://github.com/fluxcd/flux) running on your Kubernetes cluster. If you are new to GitOps, familiarize yourself by reading through some documentation [here](gitops.tech)

Flux is a Kubernetes operator that can help you with pull based deployments. Have a look here to set-up [Flux](https://docs.fluxcd.io/en/latest/tutorials/get-started.html) on your cluster. But nevertheless, I will document here the steps to set it up!

Use brew to install fluxctl

```
brew install fluxctl
```

Create the namespace

```
kubectl create ns plant-simulator-ns
```

Once you have flux operator on your Kubernetes cluster installed, you need to now set it up so that it can connect to your repository. Run the command below to do exactly this! If you clone or fork this repo, then just make sure that you use your name against the GitHub user (GHUSER)

```
export GHUSER="joesan"

fluxctl install \
--git-user=${GHUSER} \
--git-email=${GHUSER}@users.noreply.github.com \
--git-url=git@github.com:${GHUSER}/plant-simulator-deployment \
--git-path=dev \
--git-readonly=true \
--manifest-generation=true \
--namespace=plant-simulator-ns | kubectl apply -f -
```

A few things to mention here:

1. The --git-path refers to the folder in your GitHub repo where flux should look for the yaml files, here we use the base folder path

2. The --manifest-generation=true is needed because we are using Kustomize to compose the deployment

3. The --git-readonly=true tells that Flux only has read access to your repo

4. The --namespace=plant-simulator-ns is where you have installed flux into on your cluster

So here are some logs on my Mac that shows the flux containers being set up and running:

```
Joes-MacBook-Pro:~ joesan$ kubectl get pods --all-namespaces
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-6955765f44-7z9rg           1/1     Running   0          104m
kube-system   coredns-6955765f44-zv425           1/1     Running   0          104m
kube-system   etcd-minikube                      1/1     Running   0          104m
kube-system   kube-apiserver-minikube            1/1     Running   0          104m
kube-system   kube-controller-manager-minikube   1/1     Running   0          104m
kube-system   kube-proxy-wf4sq                   1/1     Running   0          104m
kube-system   kube-scheduler-minikube            1/1     Running   0          104m
kube-system   storage-provisioner                1/1     Running   1          104m
Joes-MacBook-Pro:~ joesan$ kubectl create ns plant-simulator-ns
namespace/plant-simulator-ns created
Joes-MacBook-Pro:~ joesan$ export GHUSER="joesan"
Joes-MacBook-Pro:~ joesan$ fluxctl install \
> --git-user=${GHUSER} \
> --git-email=${GHUSER}@users.noreply.github.com \
> --git-url=git@github.com:${GHUSER}/plant-simulator-deployment \
> --git-path=dev \
> --git-readonly=true \
> --manifest-generation=true \
> --namespace=plant-simulator-ns | kubectl apply -f -
serviceaccount/flux created
clusterrole.rbac.authorization.k8s.io/flux created
clusterrolebinding.rbac.authorization.k8s.io/flux created
deployment.apps/flux created
secret/flux-git-deploy created
deployment.apps/memcached created
service/memcached created
Joes-MacBook-Pro:~ joesan$ kubectl get pods --all-namespaces
NAMESPACE            NAME                               READY   STATUS              RESTARTS   AGE
kube-system          coredns-6955765f44-7z9rg           1/1     Running             0          108m
kube-system          coredns-6955765f44-zv425           1/1     Running             0          108m
kube-system          etcd-minikube                      1/1     Running             0          108m
kube-system          kube-apiserver-minikube            1/1     Running             0          108m
kube-system          kube-controller-manager-minikube   1/1     Running             0          108m
kube-system          kube-proxy-wf4sq                   1/1     Running             0          108m
kube-system          kube-scheduler-minikube            1/1     Running             0          108m
kube-system          storage-provisioner                1/1     Running             1          108m
plant-simulator-ns   flux-5476b788b9-pgbmm              0/1     Running             0          22s
plant-simulator-ns   memcached-86bdf9f56b-qc8vd         1/1     Running             0          22s
```

As a next step, you have to add the public key of your cluster to the GitHub project! 

```
fluxctl identity --k8s-fwd-ns plant-simulator-ns
```

Running the above command will give you the public key. Copy that and add it to the Deploy Keys section of your GitHub project settings. 

So we are pretty much done. Seems flux is configured to read the changes on your repo every 5 minutes as default. You can issue the below command for the changes to take place immediately:

```
fluxctl sync --k8s-fwd-ns plant-simulator-ns
```

That's pretty much it with respect to GitOps! A few more things are worth mentioning about the project structure:

```
├── .flux.yaml
├── base
│   ├── kustomization.yaml
│   ├── plant-simulator-deployment.yaml
│   ├── plant-simulator-namespace.yaml
│   └── plant-simulator-service.yaml
├── dev
│   ├── flux-patch.yaml
│   └── kustomization.yaml
└── production
    ├── flux-patch.yaml
    ├── kustomization.yaml
```

1. The base folder contains all the basic kubernetes manifests including the kustomization manifest.

2. The dev and production folders depends on the base folder and shares the manifest definitions, while overriding certain parts of it as defined in the flux-patch.yaml

3. The .flux.yaml is used by Flux to generate and update manifests. Its commands are run in the directory (dev or production). In this particular case, .flux.yaml tells Flux to generate manifests running kustomize build and update policy annotations and container images by editing flux-patch.yaml, which will implicitly applied to the manifests generated with kustomize build.

If all goes well, you should see that upon any commits into this repository, flux should have noticed about it and should have deployed your application / docker image into the Minikube cluster (or as a matter of fact in any of your Kubernetes cluster that you have under your possesion). On my machine, you can now see the new docker image up and running and ready to steam those pesky power plants!

```
Joes-MacBook-Pro:~ joesan$ kubectl get pods --all-namespaces
NAMESPACE            NAME                               READY   STATUS    RESTARTS   AGE
kube-system          coredns-6955765f44-7z9rg           1/1     Running   0          4h3m
kube-system          coredns-6955765f44-zv425           1/1     Running   0          4h3m
kube-system          etcd-minikube                      1/1     Running   0          4h3m
kube-system          kube-apiserver-minikube            1/1     Running   0          4h3m
kube-system          kube-controller-manager-minikube   1/1     Running   0          4h3m
kube-system          kube-proxy-wf4sq                   1/1     Running   0          4h3m
kube-system          kube-scheduler-minikube            1/1     Running   0          4h3m
kube-system          storage-provisioner                1/1     Running   1          4h3m
plant-simulator-ns   flux-5476b788b9-pgbmm              1/1     Running   0          135m
plant-simulator-ns   memcached-86bdf9f56b-qc8vd         1/1     Running   0          135m
plant-simulator-ns   plant-simulator-6d46dc89cb-f4bls   1/1     Running   0          40s
```

As you can see from the list of pods, our plant-simulator pod is up and running! 

## Build & compose the Kubernetes resources using Kustomize

Since our kubernetes resources are scattered across different files, for better organization we need a way to deploy them in an order and in many big projects this could get soon out of control. Fortunately, there is a project called [kustomization](https://github.com/kubernetes-sigs/kustomize) that you can use to compose the different resources into one big yml file that you can use to apply to your Kubernetes cluster. This is not needed to run this project, but I'm documenting this here just for educational piurposes. Calling the kustomize build is taken care by the flux operator as discussed in the step above.

Note: kubectl latest version contains kustomization, so no need of any additional installation!

So with this in mind, you should be able to compose the files using the following command (on the kubernetes folder of this project):

```
kubectl kustomize ./kubernetes > plant-simulator-k8s.yaml
```

The result of the above command is a single yml file that contains all the necessary k8s resources in proper order for your Kubenetes cluster!

## Tools Used

* [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) - Local Kubernetes cluster

* [Flux Kubernetes Operator](https://github.com/fluxcd/flux) - The GitOps enabler

## Contributing [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/joesan/plant-simulator/issues)

For more information on how to contribute, have a look [here](https://github.com/joesan/plant-simulator/blob/master/CONTRIBUTING.md)

## Authors / Maintainers

* *Joesan*           - [Joesan @ GitHub](https://github.com/joesan/)

See also the list of [contributors](https://github.com/joesan/plant-simulator/graphs/contributors) who helped.

## License [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

The whole project is licensed under Apache License, Version 2.0. See [LICENSE.txt](./LICENSE.txt).

## Acknowledgments

* To everybody that helped in this project
* The [Kustomize](https://kustomize.io/)
