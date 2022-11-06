## plant-simulator-deployment

This project contains the deployment / infrastructure related code for the plant-simulator digital twin project that can be found [here](https://github.com/joesan/plant-simulator) in my repository. 

![validate k8s yaml files](https://github.com/joesan/plant-simulator-deployment/workflows/ValidateKubernetesYAML/badge.svg)
  [![HitCount](https://hits.dwyl.com/joesan/plant-simulator-deployment.svg?style=flat-square&show=unique)](http://hits.dwyl.com/joesan/plant-simulator-deployment)

<ins>NOTE:</ins> No direct development in the master branch. All development activities SHOULD happen on a feature-* branch or any other branch that is not a master.

<ins>NOTE:</ins>The [Travis CI build pipeline - Cirrently Deprecated](https://travis-ci.org/github/joesan/plant-simulator/builds) or more relevant the 
[GitHub Actions](https://github.com/joesan/plant-simulator/actions) for the [plant-simulator project](https://github.com/joesan/plant-simulator), upon successful build and docker push, will write a file in this repo called ***deployment-version.txt*** which contains the deployment version that we need to run in production. So if you head over to Docker hub [here](https://hub.docker.com/r/joesan/plant-simulator/tags?page=1&ordering=last_updated), 
you will see that the latest tag version and the deployment-version.txt will be the same. Additionally, the values.yaml also gets this tag release version of the docker image updated via the Travis CI build for the plant-simulator project.

For a description / understanding of this project's folder structure and how to access the services / API's rendered by the plant-simulator application running inside the k8s cluster, have a look [here](https://github.com/joesan/plant-simulator-deployment/tree/master/base)

This project contains all it is necessary to run the [plant-simulator](https://github.com/joesan/plant-simulator) application in a kubernetes cluster - the [GitOps](gitops.tech) way! For scripts to set up the Kubernetes cluster on a cloud environment, have a look [here](https://github.com/joesan/k8s-infrastructure)

![GitOps Workflow](https://github.com/joesan/plant-simulator-deployment/blob/master/GitOps_Workflow.JPG)

From the image description (sorry for the free hand drawing), you could see that GitOps paves the way for some real CD right after a CI.

A typical workflow in this case (in this project, but applies equally good to any project) would look like the following:

1. A developer works on a task in a specific branch of the [plant-simulator](https://github.com/joesan/plant-simulator) project and once he finishes his work, he sends a pull request to the owner or the team lead or someone who has merge rights into the master branch

2. Assuming that the merge has happened, a CI pipeline kicks in and the usual ceremony happens (build, test, docker image, scan docker image for vulnerabilities, tag docker image and push to docker registry) and the image is deployed on your test or staging environment

3. The business comes in and performs their ceremonies on the staging - UAT tests and sign off

4. The tagged image from step 2 is then updated here in this project in one of the deployment files, depending on which application is being deployed

5. Commit the deployment file and voila, your changes should be available in production within the next few minutes! It is here where the idea of GitOps really kick in. Good indeed or?

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

NOTE: Make sure to ebnable the NGINX Ingress controller as we need Ingress later on for routing our requests to the application services! Run the following command:

```
minikube addons enable ingress

```

Now let us see what the kubectl get pods command brings up (Note that the NGINX controller is also running now):

```
Joes-MacBook-Pro:deploy joesan$ kubectl get pods --all-namespaces
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-6955765f44-4n5wh           1/1     Running   0          62s
kube-system   coredns-6955765f44-fdmsn           1/1     Running   0          62s
kube-system   etcd-minikube                      1/1     Running   0          69s
kube-system   kube-apiserver-minikube            1/1     Running   0          69s
kube-system   kube-controller-manager-minikube   1/1     Running   0          69s
kube-system   kube-proxy-84lnn                   1/1     Running   0          62s
kube-system   nginx-ingress-controller-s         1/1     Running   0          2m26s
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

Alternatively, I have a script that does both the above two steps of creating the namespace and setting up the flux operator for this project. Just run the script as beloiw:

```
Joes-MacBook-Pro:plant-simulator-deployment joesan$ sh flux-setup.sh
namespace/plant-simulator-ns created
serviceaccount/flux created
clusterrole.rbac.authorization.k8s.io/flux created
clusterrolebinding.rbac.authorization.k8s.io/flux created
deployment.apps/flux created
secret/flux-git-deploy created
deployment.apps/memcached created
service/memcached created
Joes-MacBook-Pro:plant-simulator-deployment joesan$
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

That's pretty much it with respect to GitOps! 

## Useful Hints & commands

-> Check the logs of the flux operator:

```
Joes-MacBook-Pro:deploy joesan$ kubectl logs -n plant-simulator-ns flux-5476b788b9-g7xtn
```

Where the ```flux-5476b788b9-g7xtn``` is the name of the flux operator pod running on your Kubernetes cluster. You can get this name by listing for all the pods in your cluster:

-> Get all the pods running in the cluster
```
Joes-MacBook-Pro:~ joesan$ kubectl get pods --all-namespaces
```

## Test

How to make sure that your YAML files are valid before Flux pulls them as soon as you commit them? One way to do this would be to lint it before you 
commit it, but you cannot enforce every single developer to do this step. So we automate! Have a look [here](https://github.com/joesan/plant-simulator-deployment/tree/master/test)

To do this, you just need a file called [main.yaml](https://github.com/joesan/plant-simulator-deployment/tree/master/.github/workflows). GitHub runs this automatically as soon as any commit happens! A sample run of this for this project looks like below:

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

See also the list of [contributors](https://github.com/joesan/plant-simulator-deployment/graphs/contributors) who helped.

## License [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

The whole project is licensed under Apache License, Version 2.0. See [LICENSE.txt](./LICENSE.txt).

## Acknowledgments

* To everybody that helped in this project
* The [Kustomize](https://kustomize.io/) project
