
# IBM Cloud
terraform {
  required_version = ">=1.0.0, <2.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}
variable "ibmcloud_key" {
  type = string
  description = "Key IBMCloud"
}

provider "ibm" {
  ibmcloud_api_key = "${var.ibmcloud_key}"
  region           = "us-south"
  zone             = "dal10"
}

data "ibm_pi_catalog_images" "catalog_images" {
  pi_cloud_instance_id = ibm_pi_workspace.powervs_service_instance.id
}

data "ibm_pi_images" "cloud_instance_images" {
  pi_cloud_instance_id = ibm_pi_workspace.powervs_service_instance.id
}

locals {
  #  stock_image_name = "RHEL9-SP2"
  stock_image_name = "CentOS-Stream-9"
  catalog_image = [for x in data.ibm_pi_catalog_images.catalog_images.images : x if x.name == local.stock_image_name]
  private_image = [for x in data.ibm_pi_images.cloud_instance_images.image_info : x if x.name == local.stock_image_name]
  private_image_id = length(local.private_image) > 0 ? local.private_image[0].id  : ""
}


# Crear Resource
resource "ibm_resource_group" "group" {
    name     = "demo_postgresql"
  }
# Crear WorkSpace para PVS
resource "ibm_pi_workspace" "powervs_service_instance" {
    pi_name               = "llm"
    pi_datacenter         = "dal10"
    pi_resource_group_id  = ibm_resource_group.group.id
}


# Crea Networking para PVS
resource "ibm_pi_network" "power_network" {
  #  count                = 1
  pi_network_name      = "power-network"
  pi_cloud_instance_id = ibm_pi_workspace.powervs_service_instance.id
  pi_network_type      = "pub-vlan"
  pi_cidr              = "192.168.1.0/24"

}

#Crea Networking Privada PVS
resource "ibm_pi_network" "power_network_priv" {
  #    count                = 1
    pi_network_name      = "power-network-priv"
    pi_cloud_instance_id = ibm_pi_workspace.powervs_service_instance.id
    pi_network_type      = "vlan"
    pi_cidr              = "10.168.1.0/24"
}

# ID Imagen RHEL para PVS
resource "ibm_pi_image" "power_image"  {
  pi_image_name        = "CentOS-Stream-9"
  pi_image_id          = local.catalog_image[0].image_id
  pi_cloud_instance_id = ibm_pi_workspace.powervs_service_instance.id
}

# Crea PVS
resource "ibm_pi_instance" "test-instance" {
    pi_memory             = "256"
    pi_processors         = "12"
    pi_instance_name      = "power-postgresql"
    pi_proc_type          = "shared"
    pi_image_id           = local.catalog_image[0].image_id
    pi_key_pair_name      = "ricky-key"
    pi_sys_type           = "e1080"
    pi_cloud_instance_id  = ibm_pi_workspace.powervs_service_instance.id
    pi_pin_policy         = "none"
    pi_health_status      = "OK"
    pi_network {
      network_id = ibm_pi_network.power_network.network_id
      #      ip_address = "192.168.1.4"
    }
    pi_network {
      network_id = ibm_pi_network.power_network_priv.network_id
      #      ip_address = "10.168.1.4"
    }

}
