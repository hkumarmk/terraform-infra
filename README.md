# terraform-mcinfra

A repo to host mastercard specific terraform code. Terraform code in this repo
depend on various common modules that are hosted within terraform-modules repo
or public terraform modules.

* applications/: This directory contain terraform code to deploy mc application
  specific infrastructure. The code here should apply code from modules and
  should expose all the configurations as variables.
* environments/: This directory contain the variable files (.tfvars files) for
  application infrastructure in various environments/datacenters.

