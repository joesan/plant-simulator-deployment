### plant-simulator-deployment project structure

Let us explore about how the folder structure is organized!

```
├── .flux.yaml
├── base
│   ├── application
│       ├── kustomization.yaml
│       ├── plant-simulator-deployment.yaml
│       ├── plant-simulator-namespace.yaml
│       └── plant-simulator-service.yaml
│   ├── monitoring
│       ├── todo.yaml
│       ├── todo.yaml
│       ├── todo.yaml
│       └── todo.yaml
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

## Hostname Access

Once you have everything set up and running on Minikube, there is this one last step that needs to be done. If you want your application to be reachable via a hostname instead of the IP address, where the hostname is configured in the [ingress rule configuration file](https://github.com/joesan/plant-simulator-deployment/blob/master/base/application/plant-simulator-ingress-service.yaml). 

We need to now add the hostname / ip mapping to the /etc/hosts file on your machine or to be more precisely, to the machine where your kubernetes cluster is running. In my case it is the Minikube cluster running on my Mac!

```
Joes-MacBook-Pro:~ joesan$ kubectl get ingress --all-namespaces
NAMESPACE            NAME                      HOSTS                                                  ADDRESS          PORTS   AGE
plant-simulator-ns   plant-simulator-ingress   grafana.local,prometheus.local,plant.simulator.local   192.168.99.103   80      4h56m
```

Add the following line to the /etc/hosts

```
192.168.99.103   plant-simulator.local
```

With that step done, you can now access the application using the hostname. For example., give the following URL a try:

```
http://plant-simulator.local/plantsim/powerplants
```

The above command will fetch the list of all Power Plants that are configured for this application. For more API's have a look [here](https://github.com/joesan/plant-simulator/wiki)
