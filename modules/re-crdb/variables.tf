#### Required Variables

####### Create Cluster Variables
####### Node and DNS outputs used to Create Cluster
#### created during node module and used as outputs (no input required)
variable "dns_fqdn1" {
    description = "."
    default = ""
}

variable "dns_fqdn2" {
    description = "."
    default = ""
}

############# Create RE Cluster Variables

#### Cluster Inputs
#### RE Cluster Username
variable "re_cluster_username" {
    description = "redis enterprise cluster username"
}

#### RE Cluster Password
variable "re_cluster_password" {
    description = "redis enterprise cluster password"
}

#### RE CRDB DB variable inputs
variable "crdb_db_name" {
    description = "redis enterprise cluster password"
}

variable "crdb_port" {
    description = "redis enterprise cluster password"
}

variable "crdb_memory_size" {
    description = "redis enterprise cluster password"
}

variable "crdb_replication" {
    description = "redis enterprise cluster password"
}

variable "crdb_aof_policy" {
    description = "redis enterprise cluster password"
}

variable "crdb_sharding" {
    description = "redis enterprise cluster password"
}

variable "crdb_shards_count" {
    description = "redis enterprise cluster password"
}