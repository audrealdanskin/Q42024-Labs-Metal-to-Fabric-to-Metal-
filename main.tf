# define provider version

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
  plan             = "c3.small.x86"
  metro            = "da"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "my_project_id"
}

resource "equinix_metal_device" "test2" {
  hostname         = "test2"
  plan             = "c3.small.x86"
  metro            = "dc"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = "my_project_id"
}

resource "equinix_metal_vlan" "vlan1" {
  description = "VLAN in Dallas"
  metro       = "da"
  project_id  = "my_project_id"
  vxlan       = "812"
}

resource "equinix_metal_vlan" "vlan2" {
  description = "VLAN in Washington"
  metro       = "dc"
  project_id  = "my_project_id"
  vxlan       = "812"

}

resource "equinix_metal_device_network_type" "test1" {
  device_id = equinix_metal_device.test1.id
  type      = "hybrid"
}

resource "equinix_metal_port_vlan_attachment" "test1" {
  device_id = equinix_metal_device_network_type.test1.id
  port_name = "eth1"
  vlan_vnid = 434
}

resource "equinix_metal_device_network_type" "test2" {
  device_id = equinix_metal_device.test2.id
  type      = "hybrid"
}

resource "equinix_metal_port_vlan_attachment" "test2" {
  device_id = equinix_metal_device_network_type.test2.id
  port_name = "eth1"
  vlan_vnid = 434
}

resource "equinix_metal_vlan" "vlan1000" {
  project_id = "my_project_id"
  metro      = "DA"
}

resource "equinix_metal_connection" "audreametal2" {
  name               = "tf-metal-from-port"
  project_id         = "my_project_id"
  type               = "shared"
  redundancy         = "primary"
  metro              = "DA"
  speed              = "200Mbps"
  service_token_type = "z_side"
  contact_email      = "adanskin@equinix.com"
  vlans              = [equinix_metal_vlan.vlan1000.vxlan]
}


