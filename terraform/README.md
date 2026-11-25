## Terraform IaC

Terraform infrastructure as code definitions for AzureLab infrastructure.


#### Versions

| Version | Date       | Author   |
| ------- | ---------- | -------- |
| 1.0     | 2026-11-25 | mari0ffc |
|         |            |          |


#### Overview

Initial terraform code creating Virtual Networks divided to proper subnets left to configure by the network team using address range globals defined in `variables.tf`.

#### How it works

Terraform outputs a `.tfstate` file, which is just a JSON file which contains information about resource configuration, and can be applied to cloud. 

### Guidelines

- Client secrets and subscription IDs must not be commited, since this is a public repo
- `.tfstate.`, `.tfvars` and `.tfstate.backup` files and files under `.terraform/` directory should not be commited
- ```terraform fmt``` usage before commiting is highly advised, as it keeps formatting standarized

### Deploying terraform

#### Prerequisites

- Terraform 1.9 or greater
- AzureCLI version 4.0.0 or greater

#### Azure authentication
1. In command prompt type ```az login```. This will open a prompt window asking you to log into your microsoft account.
2. After logging in, there will appear default tenant and subscription details. Save subscription ID for the next step.
3. Export your subscription ID as an environment variable. In bash it's 
```shell
export ARM_SUBSCRIPTION_ID=00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```
For PowerShell see [link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide#specifying-subscription-id-is-now-mandatory)

#### Deploying terraform infrastructure
1. Make sure to be in terraform directory ```cd terraform```
2. Then, initialize terraform state with ```terraform init```
3. In order to validate the config use ```terraform validate```
4. Run ```terraform plan``` to see the summary of changes we made to the config

> [!WARNING]
> After uploading the configuration to cloud, azure will actively take money from your account for the resources used. After finishing work with deployed configuration, use ```terraform destroy``` in order to free the resources.

5. Finally, to upload the config to your azure account execute ```terraform apply```. 