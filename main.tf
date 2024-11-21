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
  auth_token = "my_auth_token"
 client_id = "my_client_id"

client_secret = "my_client_secret"

}

#specs of server and machine  
 resource "equinix_metal_device" "test1" {
  hostname         = "test1"
  plan             = "m3.small.x86"
  metro            = "da"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "my_project_id"
  user_data = format("#!/bin/bash\napt update\napt install vlan\nmodprobe 8021q\necho '8021q' >> /etc/modules-load.d/networking.conf\nip link add link bond0 name bond0.%g type vlan id %g\nip addr add 192.168.100.1/24 brd 192.168.100.255 dev bond0.%g\nip link set dev bond0.%g up", equinix_metal_vlan.vlan1.vxlan, equinix_metal_vlan.vlan1.vxlan, equinix_metal_vlan.vlan1.vxlan, equinix_metal_vlan.vlan1.vxlan)
}
resource "equinix_metal_device_network_type" "test1" {
  device_id = equinix_metal_device.test1.id
  type      = "hybrid-bonded"
}
resource "equinix_metal_port_vlan_attachment" "test1" {
  device_id = equinix_metal_device_network_type.test1.id
  port_name = "bond0"
  vlan_vnid = equinix_metal_vlan.vlan1.vxlan
}

resource "equinix_metal_vlan" "vlan2" {
  project_id = "my_project_id"
  metro      = "DC"
}
resource "equinix_metal_device" "test2" {
  hostname         = "test2"
  plan             = "m3.small.x86"
  metro            = "dc"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "my_project_id"
  user_data = format("#!/bin/bash\napt update\napt install vlan\nmodprobe 8021q\necho '8021q' >> /etc/modules-load.d/networking.conf\nip link add link bond0 name bond0.%g type vlan id %g\nip addr add 192.168.100.2/24 brd 192.168.100.255 dev bond0.%g\nip link set dev bond0.%g up", equinix_metal_vlan.vlan2.vxlan, equinix_metal_vlan.vlan2.vxlan, equinix_metal_vlan.vlan2.vxlan,equinix_metal_vlan.vlan2.vxlan)
}


resource "equinix_metal_device_network_type" "test2" {
  device_id = equinix_metal_device.test2.id
  type      = "hybrid-bonded"
}

resource "equinix_metal_port_vlan_attachment" "test2" {
  device_id = equinix_metal_device_network_type.test2.id
  port_name = "bond0"
  vlan_vnid = equinix_metal_vlan.vlan2.vxlan
}
