provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "rg" {
  count = var.resource_group == "Default" ? 0 : 1
  name  = var.resource_group
}

data "ibm_is_security_group" "default-sg" {
  name       = "${var.vpc}-default-security-group"
  depends_on = [ibm_is_vpc.vpc]
}

data "ibm_is_image" "jh-image" {
  name = var.jh_image
}

data "ibm_is_image" "adm1-image" {
  name = var.adm1_image
}

data "ibm_is_ssh_key" "keys" {
  for_each = toset([for key in var.keys : tostring(key)])
  name     = each.value
}

locals {
  keys = [
    for key in data.ibm_is_ssh_key.keys : key.id
  ]
}

resource "ibm_is_vpc" "vpc" {
  name                        = var.vpc
  tags                        = var.tags
  resource_group              = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  address_prefix_management   = "manual"
  classic_access              = var.classic_access
  default_security_group_name = "${var.vpc}-default-security-group"
  default_routing_table_name  = "${var.vpc}-default-routing-table"
  default_network_acl_name    = "${var.vpc}-default-network-acl"
}

resource "ibm_is_vpc_address_prefix" "prefix1" {
  cidr       = var.subnets["subnet1"]
  name       = "${var.vpc}-${var.zones["zone1"]}-ap"
  vpc        = ibm_is_vpc.vpc.id
  zone       = var.zones["zone1"]
  depends_on = [ibm_is_vpc.vpc]
}

resource "ibm_is_vpc_address_prefix" "prefix2" {
  cidr       = var.subnets["subnet2"]
  name       = "${var.vpc}-${var.zones["zone2"]}-ap"
  vpc        = ibm_is_vpc.vpc.id
  zone       = var.zones["zone2"]
  depends_on = [ibm_is_vpc.vpc]
}

resource "ibm_is_vpc_address_prefix" "prefix3" {
  cidr       = var.subnets["subnet3"]
  name       = "${var.vpc}-${var.zones["zone3"]}-ap"
  vpc        = ibm_is_vpc.vpc.id
  zone       = var.zones["zone3"]
  depends_on = [ibm_is_vpc.vpc]
}

resource "ibm_is_public_gateway" "pgw1" {
  name           = "${var.vpc}-${var.zones["zone1"]}-pgw"
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zones["zone1"]
  depends_on     = [ibm_is_vpc.vpc]
}

resource "ibm_is_public_gateway" "pgw2" {
  name           = "${var.vpc}-${var.zones["zone2"]}-pgw"
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zones["zone2"]
  depends_on     = [ibm_is_vpc.vpc]
}

resource "ibm_is_public_gateway" "pgw3" {
  name           = "${var.vpc}-${var.zones["zone3"]}-pgw"
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zones["zone3"]
  depends_on     = [ibm_is_vpc.vpc]
}

resource "ibm_is_subnet" "subnet1" {
  ipv4_cidr_block = var.subnets["subnet1"]
  name            = "${var.vpc}-${var.zones["zone1"]}-sn"
  resource_group  = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.zones["zone1"]
  public_gateway  = ibm_is_public_gateway.pgw1.id
  depends_on = [
    ibm_is_vpc_address_prefix.prefix1,
    ibm_is_public_gateway.pgw1
  ]
}

resource "ibm_is_subnet" "subnet2" {
  ipv4_cidr_block = var.subnets["subnet2"]
  name            = "${var.vpc}-${var.zones["zone2"]}-sn"
  resource_group  = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.zones["zone2"]
  public_gateway  = ibm_is_public_gateway.pgw2.id
  depends_on = [
    ibm_is_vpc_address_prefix.prefix2,
    ibm_is_public_gateway.pgw2
  ]
}

resource "ibm_is_subnet" "subnet3" {
  ipv4_cidr_block = var.subnets["subnet3"]
  name            = "${var.vpc}-${var.zones["zone3"]}-sn"
  resource_group  = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.zones["zone3"]
  public_gateway  = ibm_is_public_gateway.pgw3.id
  depends_on = [
    ibm_is_vpc_address_prefix.prefix3,
    ibm_is_public_gateway.pgw3
  ]
}

resource "ibm_is_security_group" "bastion-sg" {
  name           = "${var.vpc}-bastion-sg"
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = ibm_is_vpc.vpc.id
  depends_on     = [ibm_is_vpc.vpc]
}

resource "ibm_is_security_group" "maintenance-sg" {
  name           = "${var.vpc}-maintenance-sg"
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = ibm_is_vpc.vpc.id
  depends_on     = [ibm_is_security_group.bastion-sg]
}

resource "ibm_is_security_group_rule" "bastion-inbound-rule-icmp" {
  group     = ibm_is_security_group.bastion-sg.id
  direction = "inbound"
  icmp {
    type = 8
    code = 0
  }
  depends_on = [ibm_is_security_group.bastion-sg]
}

resource "ibm_is_security_group_rule" "bastion-inbound-rule-ssh" {
  group     = ibm_is_security_group.bastion-sg.id
  direction = "inbound"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.bastion-inbound-rule-icmp]
}

resource "ibm_is_security_group_rule" "maintenance-outbound-rule-dns-udp" {
  group     = ibm_is_security_group.maintenance-sg.id
  direction = "outbound"
  udp {
    port_min = 53
    port_max = 53
  }
  depends_on = [ibm_is_security_group.maintenance-sg]
}

resource "ibm_is_security_group_rule" "maintenance-outbound-rule-dns-tcp" {
  group     = ibm_is_security_group.maintenance-sg.id
  direction = "outbound"
  tcp {
    port_min = 53
    port_max = 53
  }
  depends_on = [ibm_is_security_group_rule.maintenance-outbound-rule-dns-udp]
}

resource "ibm_is_security_group_rule" "maintenance-outbound-rule-http" {
  group     = ibm_is_security_group.maintenance-sg.id
  direction = "outbound"
  tcp {
    port_min = 80
    port_max = 80
  }
  depends_on = [ibm_is_security_group_rule.maintenance-outbound-rule-dns-tcp]
}

resource "ibm_is_security_group_rule" "maintenance-outbound-rule-https" {
  group     = ibm_is_security_group.maintenance-sg.id
  direction = "outbound"
  tcp {
    port_min = 443
    port_max = 443
  }
  depends_on = [ibm_is_security_group_rule.maintenance-outbound-rule-http]
}

resource "ibm_is_security_group_rule" "maintenance-inbound-rule-ssh" {
  group     = ibm_is_security_group.maintenance-sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.bastion-sg.id
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.maintenance-outbound-rule-https]
}

resource "ibm_is_security_group_rule" "bastion-outbound-rule-ssh" {
  group     = ibm_is_security_group.bastion-sg.id
  direction = "outbound"
  remote    = ibm_is_security_group.maintenance-sg.id
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.maintenance-inbound-rule-ssh]
}

resource "ibm_is_instance" "bh1" {
  name    = "${var.vpc}-bh1"
  tags    = var.tags
  image   = data.ibm_is_image.jh-image.id
  profile = var.jh_profile

  boot_volume {
    name = "${var.vpc}-bh1-boot-volume"
  }

  primary_network_interface {
    name            = "${var.vpc}-bh1-primary-interface"
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.bastion-sg.id]
  }

  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zones["zone1"]
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  keys           = local.keys[*]
  depends_on     = [ibm_is_security_group.bastion-sg]
}

resource "ibm_is_floating_ip" "fip1" {
  name           = "${var.vpc}-bh1-fip"
  tags           = var.tags
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  target         = ibm_is_instance.bh1.primary_network_interface[0].id
  depends_on     = [ibm_is_instance.bh1]
}

resource "ibm_is_instance" "bh2" {
  name    = "${var.vpc}-bh2"
  tags    = var.tags
  image   = data.ibm_is_image.jh-image.id
  profile = var.jh_profile

  boot_volume {
    name = "${var.vpc}-bh2-boot-volume"
  }

  primary_network_interface {
    name            = "${var.vpc}-bh2-primary-interface"
    subnet          = ibm_is_subnet.subnet2.id
    security_groups = [ibm_is_security_group.bastion-sg.id]
  }

  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zones["zone2"]
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  keys           = local.keys[*]
  depends_on     = [ibm_is_security_group.bastion-sg]
}

resource "ibm_is_floating_ip" "fip2" {
  name           = "${var.vpc}-bh2-fip"
  tags           = var.tags
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  target         = ibm_is_instance.bh2.primary_network_interface[0].id
  depends_on     = [ibm_is_instance.bh2]
}

locals {
  adm1_subnet1_id = var.adm1_subnet == "subnet1" ? ibm_is_subnet.subnet1.id : ""
  adm1_subnet2_id = var.adm1_subnet == "subnet2" ? ibm_is_subnet.subnet2.id : ""
  adm1_subnet3_id = var.adm1_subnet == "subnet3" ? ibm_is_subnet.subnet3.id : ""
  adm1_subnet_id  = coalesce(local.adm1_subnet1_id, local.adm1_subnet2_id, local.adm1_subnet3_id)
}

resource "ibm_is_instance" "adm1" {
  count          = var.adm1_profile != null ? 1 : 0
  name           = "${var.vpc}-adm1"
  tags           = var.tags
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.adm1_zone
  image          = data.ibm_is_image.adm1-image.id
  profile        = var.adm1_profile
  keys           = local.keys[*]
  depends_on     = [ibm_is_security_group.maintenance-sg]

  boot_volume {
    name = "${var.vpc}-adm1-boot-volume"
    size = 250
  }

  primary_network_interface {
    name   = "${var.vpc}-adm1-primary-interface"
    subnet = local.adm1_subnet_id
    security_groups = [
      data.ibm_is_security_group.default-sg.id,
      ibm_is_security_group.maintenance-sg.id
    ]
  }
}

resource "ibm_is_instance_volume_attachment" "adm1-data-volume-attachment" {
  instance                           = ibm_is_instance.adm1[0].id
  tags                               = var.tags
  count                              = var.adm1_profile != null && var.adm1_data_volume_size != "10" ? 1 : 0
  name                               = "${var.vpc}-adm1-data-volume-attachment"
  profile                            = "10iops-tier"
  capacity                           = var.adm1_data_volume_size
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
  volume_name                        = "${var.vpc}-adm1-data-volume"
}

