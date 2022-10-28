#################################################
# GET CLUSTERS DATA
#################################################

data "nutanix_clusters" "clusters" {}

locals {
  cluster1 = [
    for cluster in data.nutanix_clusters.clusters.entities :
    cluster.metadata.uuid if cluster.service_list[0] != "PRISM_CENTRAL"
  ][0]
}

#################################################
# CREATE VPC
#################################################

resource "nutanix_vpc" "vpc_tf" {
  name = "YM-VPC-DEV-TF"

  external_subnet_reference_name = [
    var.EXTERNAL_SUBNET
  ]
}
  
#################################################
# CREATE OVERLAY SUBNET
#################################################

resource "nutanix_subnet" "subnetOverlay" {
  // create a subnet in a VPC : OVERLAY (not VLAN)
  name        = "YM-LS-Web-Dev-TF"
  subnet_type                = "OVERLAY"
  subnet_ip                  = "192.168.1.0"
  prefix_length              = 24
  default_gateway_ip         = "192.168.1.1"
  ip_config_pool_list_ranges = ["192.168.1.10 192.168.1.20"]
  dhcp_domain_name_server_list = ["8.8.8.8"]
  vpc_reference_uuid = nutanix_vpc.vpc_tf.metadata.uuid 
  depends_on = [
    nutanix_vpc.vpc_tf
  ]
}

data "nutanix_subnet" "subnet" {
subnet_name = var.EXTERNAL_SUBNET
}

#################################################
# CREATE DEFAULT ROUTE
#################################################

resource "nutanix_static_routes" "static_routes" {
  vpc_name = "YM-VPC-DEV-TF"

  default_route_nexthop {
    external_subnet_reference_uuid = data.nutanix_subnet.subnet.id
  }

  depends_on = [nutanix_vpc.vpc_tf]
}

#################################################
# CREATE VM
#################################################

resource "nutanix_image" "centos8" {
  name = "centos8"
  source_uri  = "http://10.42.194.11/workshop_staging/CentOS7.qcow2"
  description = "centos 7 image"
}

resource "nutanix_virtual_machine" "vm_tf" {
  name                 = "YM-WEB-DEV-TF"
  num_vcpus_per_socket = 1
  num_sockets          = 1
  memory_size_mib      = 2048
  cluster_uuid         = local.cluster1
  guest_customization_cloud_init_user_data = filebase64("./cloudinit.yaml")

  nic_list {
    subnet_uuid = nutanix_subnet.subnetOverlay.id
  }

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = nutanix_image.centos8.id
    }
    device_properties {
      disk_address = {
        device_index = 0
        adapter_type = "SCSI"
      }

      device_type = "DISK"
    }
  }
  disk_list {
    disk_size_mib   = 100000
    disk_size_bytes = 104857600000
  }

  disk_list {
    disk_size_bytes = 0

    data_source_reference = {}

    device_properties {
      device_type = "CDROM"
      disk_address = {
        device_index = "1"
        adapter_type = "SATA"
      }
    }
  }
  depends_on = [nutanix_subnet.subnetOverlay]
}

#################################################
# CREATE FLOATING IP
#################################################

resource "nutanix_floating_ip" "fip" {
  external_subnet_reference_name = var.EXTERNAL_SUBNET

  vm_nic_reference_uuid = nutanix_virtual_machine.vm_tf.nic_list[0].uuid
  
  depends_on = [
    nutanix_virtual_machine.vm_tf
  ]
}

#################################################
# GET FLOATING IP
#################################################

data "nutanix_floating_ip" "fip4"{
    floating_ip_uuid = resource.nutanix_floating_ip.fip.id
  }

output "FLOATING_IP" {
    value = data.nutanix_floating_ip.fip4.status[0].resources[0].floating_ip
  }

resource "null_resource" "installweb" {
  provisioner "remote-exec" {
  connection {
        type     = "ssh"
        host     = data.nutanix_floating_ip.fip4.status[0].resources[0].floating_ip
        user     = "root"
        password = "nutanix/4u"
      }  
      inline = [
          "sudo yum update -y",
          "sudo yum install nginx -y",
          "sudo systemctl start nginx",
          "sudo systemctl enable nginx",
          "sudo systemctl stop firewalld",
          "sudo systemctl disable firewalld",
          "sudo setenforce 0",
          "sudo yum install git -y",
          "git clone https://github.com/atlasblue/webdev.git",
          "mv -f webdev/* /usr/share/nginx/html",
        ]
    }
  
depends_on = [nutanix_floating_ip.fip]
}
