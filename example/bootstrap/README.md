# Bootstrapping Terraform
## Overview
Included in this directory is sample Terraform code to "bootstrap" the initial terraform state management resources. It is a best practice to use a state backend such as S3 and a locking mechanism such as DynamoDB when using Terraform. See the [docs](https://www.terraform.io/docs/backends/state.html) for more info.

However there is a chicken/egg problem when dealing with these first resources. Terraform users are left to decide for themselves how they will create these initial Terraform state management resources. 

Since this bootstrap code creates such Terraform state management resources, special care must be taken to save the resultant Terraform state file. **Be aware that this state is only saved to a local file named `terraform.tfstate`. You may want to consider checking this state file into git.** 


## Creating Resources
1. Create the state management resources:
```
# Replace my-state-bucket and my-lock-table with your preferred names
terraform init
terraform apply \
    -var="state_bucket_name=my-state-bucket" \
    -var="state_lock_table_name=my-lock-table"
```
2. The names of the state bucket and state lock table will be outputted after the successful apply. Take these values and use them in when deploying the serverless-jenkins module.

