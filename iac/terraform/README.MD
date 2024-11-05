terraform init -var-file="workspaces/dev.tfvars"
terraform plan -var-file="workspaces/dev.tfvars"
terraform apply -var-file="workspaces/dev.tfvars" --auto-approve



terraform plan -out main.tfplan

terraform apply main.tfplan