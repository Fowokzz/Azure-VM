### Azure Monitoring Script

## Overview

This Terraform script automates the creation of a Linux virtual machine in Azure. It includes the setup of a resource group, virtual private network, subnets, and other necessary dependencies for efficient server operation. Additionally, a custom data template file is included to install and configure specific features on the server upon its automatic creation.

### Steps to Run the Script

Clone Repository: Clone this repository to your local machine.

Navigate to Directory: Navigate to the directory containing the script. cd <directory-path>

Login to Azure: Use Azure CLI to login and authenticate with your Azure account. az login --use-device-code 

Set Subscription: Set the specific Azure subscription to use. az account set --subscription <subscription-name-or-id>

Initialize Terraform: Initialize Terraform in the directory. `terraform init`

Review Variables: Review the variables in the <variables.tf> file and provide appropriate values in the <terraform.tfvars> file.

Preview changes: create an execution plan, which allows you to preview the changes that Terraform plans to make to your infrastructure `terraform plan`

Execute Script: Execute the Terraform script to create resources in Azure. `terraform apply`

Destroy Resources: Permanently destroys the resources created in Azure. terraform destroy P.S: YOU CAN ONLY USE THIS IF YOU'VE NOT MANUALLY EDITED THE SCRIPT AFTER RUNNING TERRAFORM APPLY
