# atlas-terraform
Link used for EKS: https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks

Run the following command to retrieve the access credentials for your cluster and configure kubectl.
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name) --profile tfuser