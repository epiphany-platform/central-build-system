# How to create Central Build System (CBS)

  - [Peered VNET for access private cluster](#peered-vnet-for-access-private-cluster)
    - [Virtual machine for running code](#virtual-machine-for-running-code)
    - [Connect from localhost through VPN](#connect-from-localhost-through-vpn)
  - [Create Azure credentials](#create-azure-credentials)
  - [Install CBS itself](#install-cbs-itself)
    - [Terraform state](#terraform-state)
    - [Terraform vars](#terraform-vars)
    - [Azure credentials](#azure-credentials)
    - [Running terraform code](#running-terraform-code)
  - [DNS names](#dns-names)

CBS is created with terraform on MS Azure cloud.
All needed sources except secrets and [some specific variable values](#Terraform-vars) can be found inside this repo.
It is designed to be able to be moved to [the epiphany modules](https://github.com/epiphany-platform/epiphany/blob/develop/docs/home/COMPONENTS.md) as easy as possible.

## Peered VNET for access private cluster

One of the element of CBS is private AKS cluster.

It has no public IP address so we need to be in the private network to access it.
We can achieve that by running our code from:
- virtual machine in (peered) VNET 
- localhost by connecting through Azure VPN

<br>

### Virtual machine for running code

We will create a private cluster so by default there will be no access to it from outside of Azure cloud (or our VNET to be more specific) - but we will change it later.
The easiest way to achieve it is to create a new resource group with VNET and VM inside it.

On that machine you should install:

* [az](https://docs.microsoft.com/pl-pl/cli/azure/install-azure-cli)
* [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

As soon as you aer all setup up, you're ready to go on with the *build system* itself.
This can be easily done with running terraform module for that:

```shell
git clone git@github.com:epiphany-platform/build-system.git

cd build-system/technical/sources/init_vnet/
terraform init
terraform apply #type yes
```

As an output you get a public IP of created VM. Please login to this vm as user `azureuser` using the ssh key from `~/.ssh/` direcory. If you don't have such key, please create one.

In the output you will also get three another lines which we will use later:

```shell
vm_rg_name = ""
vm_vnet_id = ""
vm_vnet_name = ""
```

### Connect from localhost through VPN

We can also take the send option and create VNET with Virtual Network Gateway and peer it with kubernetes VPN.

Creation of this is out of CBS scope but below you can find directions which allow you to configure it in a correct way.<br>In this case you have to properly configure peering.
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

In the terraform code inside peering module this is already set.<br>
<br>

## Create Azure credentials

You can run terraform on your credentials or create an Azure application for it - which is what we recommend.
More information on azure identities can be found [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals).

If you decide to go with Azure application you can run the below code and grant created application permission in Azure if needed.

```shell
az login
az account list # get subscription from id field
export SUBSCRIPTION_ID="SUBSCRIPTION_ID" # replace `SUBSCRIPTION_ID` the `id` from previous command
export SERVICE_PRINCIPAL="some_meaningful_name" # replace `some_meaningful_name` the `service principal` name
az account set --subscription="${SUBSCRIPTION_ID}"
az ad sp create-for-rbac --scopes="/subscriptions/${SUBSCRIPTION_ID}" --name="${SERVICE_PRINCIPAL}" # get appID, password, tenant, name and displayName
```

Please, keep the output of the last command in safe and confidential place.

After creation of the app credentials please go to Azure AD -> App registrations -> {your_app_name} -> Manifest and ensure you have below value:

```text
"groupMembershipClaims": "All",
```

Otherwise integration between ArgoCD and Azure AD will not work.

## Install CBS itself

Please clone the repository to the machine that can reach Kubernetes cluster and run terraform code.

```shell
cd build-system/technical/sources/terraform/envs/prod
terraform init
```

### Terraform state

This step is optional but highly recommended.

Terraform state can be kept locally or - preferably - remotely in Azure blob storage account using the *azurerm* terraform backend.
Instruction on how to create such storage account can be found [here](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage).

To keep the terraform state in Azure storage container please replace the below given example values with yours and then run:

```shell
cd sources/init_storage
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

Then run :

```shell
terraform init
```
The `backend.tf` file is ignored by git already so you do not have to worry that you will commit it by accident.<br>

Please notice, that above command needs to be run only once ( as this is initialization code.... ). If the storage account already exists ( which is most likely the case in the situation when you have already created another CBS enviroments within the subscription ) 
this resource needs to be imported into the state file of the current enviroment in order to be managed via Terraform with following command:<br>
```terraform import azurerm_storage_account.harbor_storage <azure_account_it>```
<br><br>

### Terraform vars

For build system creation terraform needs you to put all values for the below variables related mainly to your [SP](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals#service-principal-object) details.
You can do this with this command:

```shell
echo """project_name     = \"your_project_name\" 
location         = \"your_location\"
client_id        = \"AzureApplication_appId\"
client_secret    = \"AzureApplication_password\"
tenant_id        = \"AzureTenantId\"
aad_admin_groups = [\"Azure_AD_group_id\"]   # 
argo_prefix      = \"argocd-prefix\"
tekton_prefix    = \"tekton-prefix\"
domain           = \"your.domain\"
""" > terraform.tfvars
```
Legend:<br>
*aad_admin_groups - (Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster.*<br>
*argo/tekton_prefix - domain prefix for ArgoCD/Tekton* 

<br>Shell you need further assistance with Service Principal creation follow [this instructions](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal).

<br>

Also please paste 3 below lines ( with a proper values ) from output of VM creation step into the file `terraform.tfvars`:

```shell
echo """vm_rg_name = \"your_rg_name\"
vm_vnet_id = \"your_vnet_id\"
vm_vnet_name = \"your_vnet_name\"
""" >> terraform.tfvars
```

### Azure credentials

Terraform should be run as a context of service principal that [was created](#Create-Azure-credentials) specially for this purpose and has a proper permissions in the Azure subscription.
To run it we recommend to execute the below code 
supplemented with proper values:

```shell
export ARM_CLIENT_ID="AzureApplication_appId"
export ARM_CLIENT_SECRET="AzureApplication_password"
export ARM_SUBSCRIPTION_ID="Subscription_id"
export ARM_TENANT_ID="AzureTenantId"
```
More information about terraform authentication methods in Azure can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).<br><br>

### Running terraform code

```shell
terraform plan
terraform apply # answer yes when prompted
```

However, it is very likely that after some time terraform will fail.
Depending on from which machine you're running terraform, you can come across several different issues.<br>
If you're running it from your localhost you have to configure VPN client.
In both cases ( until we do not resolve feature/issue with DNS private zones ) you have to manually update your `/etc/hosts` file.
To determine values which should be put there please run below script, and put exact resource group name and kubernetes host in below format:

```shell
../../modules/k8s/arecord.sh your-k8s-rg-name https://your-cluster-dns.some_hash.privatelink.region.azmk8s.io:443
```

As an output you should get something like that:

```shell script
sudo sh -c 'echo "10.10.4.1 your-cluster-dns.some_hash.privatelink.region.azmk8s.io" >> /etc/hosts'
```

Now please copy&paste this to the command line and run it.

After that, repeat terraform apply command again:

```shell
terraform apply
```

## DNS names

ArgoCD and Tekton can be accessed by Ingress.
So it is mandatory to configure DNS names used to resolve both ArgoCD and Tekton to the correct LoadBalncer IP.
