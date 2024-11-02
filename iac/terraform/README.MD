terraform init -var-file="workspaces/dev.tfvars"
terraform plan -var-file="workspaces/dev.tfvars"
terraform apply -var-file="workspaces/dev.tfvars"