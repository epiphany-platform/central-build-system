## Goal
The code will let you automatically mange the SSL certificates request & deploy process on Your CBS kubernetes cluster

## Source docummentation
This work out is based on [this cert-manager project](https://cert-manager.io/docs/tutorials/acme/ingress/#step-5-deploy-cert-manager).

AzureDNS documentation can be found [here](https://cert-manager.io/docs/configuration/acme/dns01/azuredns/#service-principal).


## Installation steps
This coverage is focused on *dns-01* type of ACME challenge available to use as there is no need for public ingres exposing in this method. However, if you prefer to use the http-01 method - you can follow the appropriate section of the base project documentation.  
Follow the below steps to successfully instal the cert automation:


 -  prepare the necessery AZ account:  
 ```dns-01/dnschallenge_SP_create.sh```
 - install the latest ( or any other of your chice  ) version of the cert-manager project CRD boundle:  
 ```kubectl apply -f  https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml```

 - update ```hostedZoneName``` in ```dns-01/k8s-certmgr-le-prod-dns01-clissuer.yaml``` acordingly

 - install the ClusterIssuer ( the main component, that will take care of the whole process of certificates managing ):  
 ```kubectl apply -f dns-01/k8s-certmgr-le-prod-dns01-clissuer.yaml```
 
 - add this annotation to any ingress instances that you want to be managed by the ClusterIssuer:
  ```
    metadata:
      annotations:
        cert-manager.io/cluster-issuer: le-prod-dns-clisr
  ```
  You are all set up.
  