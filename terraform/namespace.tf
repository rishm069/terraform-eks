module "namespaces" {
  source = "./namespaces"
  
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_name = local.cluster_name
}
