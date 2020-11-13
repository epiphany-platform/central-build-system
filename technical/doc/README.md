# How to create Central Build System (CBS)

CBS was created with terraform.
All sources except secrets - are inside this repo.
It is designed to be easily (as possible) moved to epiphany modules.

## Peered VNET for access to private cluster

One of the element of CBS is private aks cluster.

It has no public IP address so to get to it we have to be in private network.
We can achieve that by running our code from virtual machine in (peered) VNET or from localhost by connecting through VPN.

### Virtual machine for running code

We will create a private cluster so by default there will be no access to it outside of Azure (or our VNET to be more specific).
But we will change it later.

I think the easiest way is to create a new resource group with VNET and VM inside it.

On that machine you should install:

* [az](https://docs.microsoft.com/pl-pl/cli/azure/install-azure-cli)
* [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

When you will have that you will be ready to go with the build system itself.

This all work can be easily done by running terraform module for that.

Just run below commands:

```shell
git clone git@github.com:epiphany-platform/build-system.git

cd build-system/technical/sources/init_vnet/
terraform init
terraform apply #type yes
```

In output you get public IP of created VM. Please login to it as user: `azureuser`. Its ssh key is your public key taken from `~/.ssh/id_rsa.pub` if you don't have such key please create one.

In output you will get also 3 another lines which we will use later:

```shell
vm_rg_name = ""
vm_vnet_id = ""
vm_vnet_name = ""
```

### Connect from localhost through VPN

We can also create VNET with Virtual Network Gateway and peer it with kubernetes VPN.

Creation of this is out of CBS scope but below you can find directions which allow you to configure it this way.

In this case you have to properly configure peering.
In the VPN VNET peering you have to set below setting:

```text
Traffic to remote virtual network: Allow (default)
Traffic forwarded from remote virtual network: Allow (default)
Virtual network gateway: Use this virtual network's gateway
```

In the AKS VNET  peering you have to set below setting:

```text
Traffic to remote virtual network: Allow (default)
Traffic forwarded from remote virtual network: Allow (default)
Virtual network gateway: Use the remote virtual network's gateway
```

In terraform code inside peering module this is already set.

## Create Azure credentials

You can run terraform on your credentials or create Azure application for it - which is what we are recommending.
More description about azure identities can be find [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals).

If you decide to go with Azure application you can run the below code and grant created application permission in Azure if needed.

```shell
az login
az account list # get subscription from id field
export SUBSCRIPTION_ID="SUBSCRIPTION_ID" # replace `SUBSCRIPTION_ID` the `id` from previous command
export SERVICE_PRINCIPAL="some_meaningful_name" # replace `some_meaningful_name` the `service principal` name
az account set --subscription="${SUBSCRIPTION_ID}"
az ad sp create-for-rbac --scopes="/subscriptions/${SUBSCRIPTION_ID}" --name="${SERVICE_PRINCIPAL}" # get appID, password, tenant, name and displayName
```

Please, keep the output of the last command in safe place.

Also after creation of your credentials please go to Azure AD -> App registrations -> {your_credentials} -> Manifest and ensure you have below value:

```text
"groupMembershipClaims": "All",
```

Otherwise integration between ArgoCD and Azure AD will not work.

## Install CBS itself

Please clone the repository to the machine that can reach Kubernetes and run terraform code.

```shell
cd build-system/technical/sources/terraform/envs/prod
terraform init
```

### Terraform remote state

This step is optional but highly recommended to use it.

Terraform state can be keep remotely in azurerm backend.
Instruction how to create such storage account is [here](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage).

To keep state in such storage account please run:

```shell
echo """terraform {
  backend \"azurerm\" {
    resource_group_name  = \"StorageAccount-ResourceGroup\"
    storage_account_name = \"abcd1234\"
    container_name       = \"tfstate\"
    key                  = \"prod.terraform.tfstate\"
  }
}
""" > backend.tf
```

And replace example values with yours.
If you decided to use it please run once again:

```shell
cd build-system/technical/sources/terraform/
terraform init
```

This file is ignored by git already so you do not have to worry that you will commit it by accident.

If you don't do that step you will keep state file on your local disk which is not recomended solution.

### Terraform vars

For build system creation terraform needs you to put all values for variables.
You can do this by below command:

```shell
echo """project_name     = \"your_project_name\"
location         = \"your_location\"
client_id        = \"AzureApplication_appId\"
client_secret    = \"AzureApplication_password\"
tenant_id        = \"AzureTenantId\"
aad_admin_groups = [\"Azure_AD_group_id\"]
argo_prefix      = \"argocd-prefix\"
tekton_prefix    = \"tekton-prefix\"
domain           = \"your.domain\"
""" > terraform.tfvars
```

Also please paste 3 below lines (with proper values) from output of VM creation into file `terraform.tfvars`:

```shell
echo """vm_rg_name = \"your_rg_name\"
vm_vnet_id = \"your_vnet_id\"
vm_vnet_name = \"your_vnet_name\"
""" >> terraform.tfvars
```

### Azure credentials

Terraform should be run as a service principal which was created especially for that and has proper permissions in the subscription.
More information about terraform authentication methods (to Azure) can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)

To run it as that credentials I recommend to execute the below code with proper values:

```shell
export ARM_CLIENT_ID="AzureApplication_appId"
export ARM_CLIENT_SECRET="AzureApplication_password"
export ARM_SUBSCRIPTION_ID="Subscription_id"
export ARM_TENANT_ID="AzureTenantId"
```

### Run terraform code

```shell
terraform plan
terraform apply #type yes
```

After some time terraform will fail.
Depending from which machine you're running terraform you will meet different issues.
If you're running it from localhost you have to configure VPN client now.
In both cases - until we do not resolve feature/issue with DNS private zones - you have to update your `/etc/hosts` file.
To determine values which should be put there please run below script, and put exact resource group name and kubernetes host in below format:

```shell
../../modules/k8s/arecord.sh your-k8s-rg-name https://your-cluster-dns.some_hash.privatelink.region.azmk8s.io:443
```

In output you should get something like that:

```shell script
sudo sh -c 'echo "10.10.4.1 your-cluster-dns.some_hash.privatelink.region.azmk8s.io" >> /etc/hosts'
```

And please paste this to command line and type your password.

After that run once again:

```shell
terraforma apply #type yes
```

## DNS names

ArgoCD and Tekton can be accessed by Ingress.

So it is mandatory to configure DNS names used for ArgoCD and Tekton to point to LoadBalncer IP.
