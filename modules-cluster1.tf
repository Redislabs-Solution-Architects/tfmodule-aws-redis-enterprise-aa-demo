########## Create an RE cluster on AWS from scratch #####
#### Modules to create the following:
#### Brand new VPC 
#### RE nodes and install RE software (ubuntu)
#### Test node with Redis and Memtier
#### DNS (NS and A records for RE nodes)
#### Create and Join RE cluster 


########### VPC Module
#### create a brand new VPC, use its outputs in future modules
#### If you already have an existing VPC, comment out and
#### enter your VPC params in the future modules
module "vpc1" {
    source             = "./modules/vpc"
    providers = {
      aws = aws.a
    }
    aws_creds          = var.aws_creds
    owner              = var.owner
    region             = var.region1
    base_name          = var.base_name1
    vpc_cidr           = var.vpc_cidr
    subnet_cidr_blocks = var.subnet_cidr_blocks
    subnet_azs         = var.subnet_azs1
}

### VPC outputs 
### Outputs from VPC outputs.tf, 
### must output here to use in future modules)
output "subnet-ids1" {
  value = module.vpc1.subnet-ids
}

output "vpc-id1" {
  value = module.vpc1.vpc-id
}

output "vpc_name1" {
  description = "get the VPC Name tag"
  value = module.vpc1.vpc-name
}

########### Node Module
#### Create RE and Test nodes
#### Ansible playbooks configure and install RE software on nodes
#### Ansible playbooks configure Test node with Redis and Memtier
module "nodes1" {
    source             = "./modules/nodes"
    providers = {
      aws = aws.a
    }
    owner              = var.owner
    region             = var.region1
    vpc_cidr           = var.vpc_cidr
    subnet_azs         = var.subnet_azs1
    ssh_key_name       = var.ssh_key_name1
    ssh_key_path       = var.ssh_key_path1
    test_instance_type = var.test_instance_type
    test-node-count    = var.test-node-count
    re_download_url    = var.re_download_url
    data-node-count    = var.data-node-count
    re_instance_type   = var.re_instance_type
    re-volume-size     = var.re-volume-size
    allow-public-ssh   = var.allow-public-ssh
    open-nets          = var.open-nets
    ### vars pulled from previous modules
    ## from vpc module outputs 
    ##(these do not need to be varibles in the variables.tf outside the modules folders
    ## since they are refrenced from the other module, but they need to be variables 
    ## in the variables.tf inside the nodes module folder )
    vpc_name           = module.vpc1.vpc-name
    vpc_subnets_ids    = module.vpc1.subnet-ids
    vpc_id             = module.vpc1.vpc-id
}

#### Node Outputs to use in future modules
output "re-data-node-eips1" {
  value = module.nodes1.re-data-node-eips
}

output "re-data-node-internal-ips1" {
  value = module.nodes1.re-data-node-internal-ips
}

output "re-data-node-eip-public-dns1" {
  value = module.nodes1.re-data-node-eip-public-dns
}

# output "test-node-eips" {
#   value = module.nodes.test-node-eips
# }

########### DNS Module
#### Create DNS (NS record, A records for each RE node and its eip)
#### Currently using existing dns hosted zone
module "dns1" {
    source             = "./modules/dns"
    providers = {
      aws = aws.a
    }
    dns_hosted_zone_id = var.dns_hosted_zone_id
    data-node-count    = var.data-node-count
    ### vars pulled from previous modules
    vpc_name           = module.vpc1.vpc-name
    re-data-node-eips  = module.nodes1.re-data-node-eips
}

#### dns FQDN output used in future modules
output "dns-ns-record-name1" {
  value = module.dns1.dns-ns-record-name
}

############## RE Cluster
#### Ansible Playbook runs locally to create the cluster
module "create-cluster1" {
  source               = "./modules/re-cluster"
  providers = {
      aws = aws.a
    }
  ssh_key_path         = var.ssh_key_path1
  region               = var.region1
  re_cluster_username  = var.re_cluster_username
  re_cluster_password  = var.re_cluster_password
  ### vars pulled from previous modules
  vpc_name             = module.vpc1.vpc-name
  re-node-internal-ips = module.nodes1.re-data-node-internal-ips
  re-node-eip-ips      = module.nodes1.re-data-node-eips
  re-data-node-eip-public-dns   = module.nodes1.re-data-node-eip-public-dns
  dns_fqdn             = module.dns1.dns-ns-record-name
  
  depends_on           = [module.vpc1, module.nodes1, module.dns1]
}

#### Cluster Outputs
output "re-cluster-url" {
  value = module.create-cluster1.re-cluster-url
}

output "re-cluster-username" {
  value = module.create-cluster1.re-cluster-username
}

output "re-cluster-password" {
  value = module.create-cluster1.re-cluster-password
}