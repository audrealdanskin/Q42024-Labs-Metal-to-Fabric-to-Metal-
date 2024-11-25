terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "2.6.0"
    }
  }
}

provider "equinix" {
  # Configuration options 
  # Credentials for only Equinix Metal resources 
  auth_token = "my_api_token"

  client_id = "my_client_id"

  client_secret = "my_client_secret"

}

resource "equinix_metal_vlan" "vlan1" {
  project_id = "my_project_id"
  metro      = "DA"
  vxlan  = 1040
}

#specs of server and machine
resource "equinix_metal_device" "metal_test1" {
  hostname         = "test1"
  plan             = "m3.small.x86"
  metro            = "DA"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "my_project_id"
  user_data = format("#!/bin/bash\napt update\napt install vlan\nmodprobe 8021q\necho '8021q' >> /etc/modules-load.d/networking.conf\nip link add link bond0 name bond0.%g type vlan id %g\nip addr add 192.168.100.1/24 brd 192.168.100.255 dev bond0.%g\nip link set dev bond0.%g up", equinix_metal_vlan.vlan1.vxlan, equinix_metal_vlan.vlan1.vxlan, equinix_metal_vlan.vlan1.vxlan, equinix_metal_vlan.vlan1.vxlan)
}

resource "equinix_metal_device_network_type" "port_type_test1" {
  device_id = equinix_metal_device.metal_test1.id
  type      = "hybrid-bonded"
}
resource "equinix_metal_port_vlan_attachment" "vlan_attach_test1" {
  device_id = equinix_metal_device_network_type.port_type_test1.id
  port_name = "bond0"  
  vlan_vnid = equinix_metal_vlan.vlan1.vxlan 
}

resource "equinix_metal_vlan" "vlan2" {
  metro       = "DC"
  project_id  = "my_project_id"
  vxlan       = 1040
}

resource "equinix_metal_device" "metal_test2" {
  hostname         = "test2"
  plan             = "m3.small.x86"
  metro            = "dc"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "my_project_id"
   user_data = format("#!/bin/bash\napt update\napt install vlan\nmodprobe 8021q\necho '8021q' >> /etc/modules-load.d/networking.conf\nip link add link bond0 name bond0.%g type vlan id %g\nip addr add 192.168.100.2/24 brd 192.168.100.255 dev bond0.%g\nip link set dev bond0.%g up", equinix_metal_vlan.vlan2.vxlan, equinix_metal_vlan.vlan2.vxlan, equinix_metal_vlan.vlan2.vxlan,equinix_metal_vlan.vlan2.vxlan)
}

resource "equinix_metal_device_network_type" "port_type_test2" {
  device_id = equinix_metal_device.metal_test2.id
  type      = "hybrid-bonded"
}

resource "equinix_metal_port_vlan_attachment" "vlan_attach_test2" {
  device_id = equinix_metal_device_network_type.port_type_test2.id
  port_name = "bond0"
  vlan_vnid = equinix_metal_vlan.vlan2.vxlan
}

## Create VC via dedciated port in metro1
/* this is the "Interconnection ID" of the "DA-Metal-to-Fabric-Dedicated-Redundant-Port" via Metal's portal*/
locals {
  conn_id1 = "connection_id"
}
data "equinix_metal_connection" "dametro1_port" {
  connection_id = local.conn_id1
}
resource "equinix_metal_virtual_circuit" "dametro1_vc" {
  connection_id = local.conn_id1
  project_id    = "_my_project_id"
  port_id       = "connection_id"
  vlan_id       = "equinix_metal_vlan.vlan1.vxlan"
  nni_vlan      = "1040"
  name          = "adanskin-tf-vc"
}
## Request a Metal connection and get a z-side token from Metal
resource "equinix_metal_connection" "example" {
  name               = "audrea-metal-port-tf"
  project_id         =  "my_project_id"
  type               = "shared"
  redundancy         = "primary"
  metro              =  "dc"
  speed              = "10Gbps"
  service_token_type = "z_side"
  contact_email      = "adanskin@equinix.com"
  vlans              = [equinix_metal_vlan.vlan2.vxlan]
}
