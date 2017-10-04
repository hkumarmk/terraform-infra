# terraform-mcinfra

A repo to host mastercard specific terraform code. Terraform code in this repo
depend on various common modules found in modules directory or public terraform modules.

* modules/: This directory contain reuseable terraform modules. The effort is to provide
  a common terraform terminology to deploy stuffs in different kind of cloud environments 
  by trying to abstract the differences as much as possible.
* applications/: This directory contain terraform code to deploy mc application
  specific infrastructure. The code here should apply code from modules and
  should expose all the configurations as variables.
* environments/: This directory contain two set of files for
  application infrastructure in various environments/datacenters.
  * terraform variable files (.tfvars files) which contain terraform variables that would be
    by the code in applications/ directory
  * backend-conig.tfvars - This file contain special set of variable to initialize terraform backend.
    This file is used to initialize terraform code with different environments.

Currently it use consul based backend to keep terraform states.

# Usage
One should use terraform command as below with this code

For example, run below set of commands to setup basic networking infrastructure on google cloud

```
# Initialize terraform code - initialize backend, cache any modules used etc

$ cd terraform-mcinfra/applications/base-networking/google/

$ terraform init -backend-config=../../../environments/base_networking/google-us-central1-prod/backend-config.tfvars
Downloading modules...
Get: file:///home/harish/code/terraform-mcinfra/modules/google/vpc

Initializing the backend...
Acquiring state lock. This may take a few moments...

# Get any modules that are used
$ terraform get

# Run terraform plan to see what changes terraform is going to apply
$ terraform plan -var-file=../../../environments/base_networking/google-us-central1-prod/terraform.tfvars

# Run terraform apply to apply the changes
$ terraform apply -var-file=../../../environments/base_networking/google-us-central1-prod/terraform.tfvars

```
