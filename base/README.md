### plant-simulator-deployment architecture

<< TODO >> Document on the folder structure and the architrecture of the deployment? Show the UI, backend and how they are connected using
services and ingress controller, how the monitoring with prometheus & grafana dashboards work.

Once you have everything set up and running on Minikube, there is this one last step that needs to be done. If you want your application to be reachable via a hostname instead of the IP address, where the hostname is configured in the [ingress rule configuration file](https://github.com/joesan/plant-simulator-deployment/blob/master/base/application/plant-simulator-ingress-service.yaml), we need to now add the hostname / ip mapping to the /etc/hosts file on your machine or to be more precisely, to the machine where your kubernetes cluster is running. In my case it is the Minikube cluster running on my Mac!

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