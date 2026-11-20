# Introduction
Terraform is the IaC tool of choice for AzureLab.
## Hosting on your azure account
1. For user authentication using a service principal with client secret is recommended. A guide to this method is located here: [link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
2. After your authentication, run commands in this directory, as follows:
```
terraform validate
```
to validate the configuration, and
```
terraform apply
```
to apply changes to the cloud.