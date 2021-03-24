# Central Build System

## Design

It was decided for Central Build System (CBS) to go with separate tool for building (*Continuous Integration*) and deploying (*Continuous Deployment*).

For building we choose [tekton](tekton.dev) and for deploying [ArgoCD](https://argoproj.github.io/argo-cd/).
You can find more information in [Comparision of CI/CD tools](https://github.com/pprach/epiphany/blob/440c276cf22d873cc91478af4777ef714c8c1642/docs/design-docs/cicd-server/comparision_cicd.md) doc.

## Architecture diagram

![Diagram_schema](./images/build_system_network_schema.png)


Architeccure comonents:

### VPN VNET

The VPN Viretual Network (VNET) is responsible for communication with the outside of Azure cloud.
That means, every user who wants to log into CBS system - has to log in to VPN VNET first.

Also this VNET is responsible for allowing external requests - like github webhooks - to communicate with our CBS system.

### Build system VNET

This VNET is core network of build system. All the essential components of AKS kubernetes cluster are deployed in this network.

### Tekton

Tekton is a *CI* component of CBS that is installed inside Kubernetes cluster.
Access to Tekton is managed by Kubernetes RBAC mechanism.
Each assigned group have got a separate namespace with their own UI so each team is able to do their stuff only inside their namespace.
Access control is integrated with Azure Active Directory.

### ArgoCD

ArgoCD is a *CD* component of CBS that is deployed inside the same Kubernetes cluster as Tekton.
It is running in separate kubernetes namespace with access restricted to admin group only.

Permissions for ArgoCD are managed by OIDC component and are integrated with Azure Active Directory.

## Installation manual

Installation and setup instructions are covered by this [document](CBS_HOWTO.md).

## Licencing

The code in this repository is distributed under this [license](LICENSE).
