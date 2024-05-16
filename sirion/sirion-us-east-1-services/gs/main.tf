provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "rg" {
  count = var.resource_group == "Default" ? 0 : 1
  name  = var.resource_group
}

data "ibm_is_vpc" "vpc" {
  name = var.vpc
}

data "ibm_is_security_group" "default-sg" {
  name = "${var.vpc}-default-security-group"
}

data "ibm_is_security_group" "bastion-sg" {
  name = "${var.vpc}-bastion-sg"
}

data "ibm_is_security_group" "maintenance-sg" {
  name = "${var.vpc}-maintenance-sg"
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

data "ibm_is_subnet" "subnet1" {
  name = "${var.vpc}-${var.zones["zone1"]}-sn"
}

data "ibm_is_subnet" "subnet2" {
  name = "${var.vpc}-${var.zones["zone2"]}-sn"
}

data "ibm_is_subnet" "subnet3" {
  name = "${var.vpc}-${var.zones["zone3"]}-sn"
}

locals {
  gs1_subnet1_id = var.gs1_subnet == "subnet1" ? data.ibm_is_subnet.subnet1.id : ""
  gs1_subnet2_id = var.gs1_subnet == "subnet2" ? data.ibm_is_subnet.subnet2.id : ""
  gs1_subnet3_id = var.gs1_subnet == "subnet3" ? data.ibm_is_subnet.subnet3.id : ""
  gs1_subnet_id  = coalesce(local.gs1_subnet1_id, local.gs1_subnet2_id, local.gs1_subnet3_id)
}

data "ibm_is_image" "gs1-image" {
  name = var.gs1_image
}

resource "ibm_is_instance" "gs1" {
  count          = var.gs1_profile != null ? var.gs1_count : 0
  name           = "${var.vpc}-gs1-${count.index}"
  tags           = var.tags
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.gs1_zone
  image          = data.ibm_is_image.gs1-image.id
  profile        = var.gs1_profile
  keys           = local.keys[*]
  depends_on     = [data.ibm_is_security_group.maintenance-sg]

  boot_volume {
    name = "${var.vpc}-gs1-${count.index}-boot-volume"
    size = 250
  }

  primary_network_interface {
    name   = "${var.vpc}-gs1-${count.index}-primary-interface"
    subnet = local.gs1_subnet_id
    security_groups = [
      data.ibm_is_security_group.default-sg.id,
      data.ibm_is_security_group.maintenance-sg.id
    ]
  }
}

resource "ibm_is_instance_volume_attachment" "gs1-data-volume-attachment" {
  count                              = var.gs1_profile != null && var.gs1_data_volume_size != "10" ? var.gs1_count : 0
  instance                           = ibm_is_instance.gs1[count.index].id
  name                               = "${var.vpc}-gs1-${count.index}-data-volume-attachment"
  tags                               = var.tags
  profile                            = "10iops-tier"
  capacity                           = var.gs1_data_volume_size
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
  volume_name                        = "${var.vpc}-gs1-${count.index}-data-volume"
}

locals {
  gs2_subnet1_id = var.gs2_subnet == "subnet1" ? data.ibm_is_subnet.subnet1.id : ""
  gs2_subnet2_id = var.gs2_subnet == "subnet2" ? data.ibm_is_subnet.subnet2.id : ""
  gs2_subnet3_id = var.gs2_subnet == "subnet3" ? data.ibm_is_subnet.subnet3.id : ""
  gs2_subnet_id  = coalesce(local.gs2_subnet1_id, local.gs2_subnet2_id, local.gs2_subnet3_id)
}

data "ibm_is_image" "gs2-image" {
  name = var.gs2_image
}

resource "ibm_is_instance" "gs2" {
  count          = var.gs2_profile != null ? var.gs2_count : 0
  name           = "${var.vpc}-gs2-${count.index}"
  tags           = var.tags
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.gs2_zone
  image          = data.ibm_is_image.gs2-image.id
  profile        = var.gs2_profile
  keys           = local.keys[*]
  depends_on     = [data.ibm_is_security_group.maintenance-sg]

  boot_volume {
    name = "${var.vpc}-gs2-${count.index}-boot-volume"
    size = 250
  }

  primary_network_interface {
    name   = "${var.vpc}-gs2-${count.index}-primary-interface"
    subnet = local.gs2_subnet_id
    security_groups = [
      data.ibm_is_security_group.default-sg.id,
      data.ibm_is_security_group.maintenance-sg.id
    ]
  }
}

resource "ibm_is_instance_volume_attachment" "gs2-data-volume-attachment" {
  count                              = var.gs2_profile != null && var.gs2_data_volume_size != "10" ? var.gs2_count : 0
  instance                           = ibm_is_instance.gs2[count.index].id
  name                               = "${var.vpc}-gs2-${count.index}-data-volume-attachment"
  tags                               = var.tags
  profile                            = "10iops-tier"
  capacity                           = var.gs2_data_volume_size
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
  volume_name                        = "${var.vpc}-gs2-${count.index}-data-volume"
}

locals {
  gs3_subnet1_id = var.gs3_subnet == "subnet1" ? data.ibm_is_subnet.subnet1.id : ""
  gs3_subnet2_id = var.gs3_subnet == "subnet2" ? data.ibm_is_subnet.subnet2.id : ""
  gs3_subnet3_id = var.gs3_subnet == "subnet3" ? data.ibm_is_subnet.subnet3.id : ""
  gs3_subnet_id  = coalesce(local.gs3_subnet1_id, local.gs3_subnet2_id, local.gs3_subnet3_id)
}

data "ibm_is_image" "gs3-image" {
  name = var.gs3_image
}

resource "ibm_is_instance" "gs3" {
  count          = var.gs3_profile != null ? var.gs3_count : 0
  name           = "${var.vpc}-gs3-${count.index}"
  tags           = var.tags
  resource_group = var.resource_group == "Default" ? null : data.ibm_resource_group.rg[0].id
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.gs3_zone
  image          = data.ibm_is_image.gs3-image.id
  profile        = var.gs3_profile
  keys           = local.keys[*]
  depends_on     = [data.ibm_is_security_group.maintenance-sg]

  boot_volume {
    name = "${var.vpc}-gs3-${count.index}-boot-volume"
    size = 250
  }

  primary_network_interface {
    name   = "${var.vpc}-gs3-${count.index}-primary-interface"
    subnet = local.gs3_subnet_id
    security_groups = [
      data.ibm_is_security_group.default-sg.id,
      data.ibm_is_security_group.maintenance-sg.id
    ]
  }
}

resource "ibm_is_instance_volume_attachment" "gs3-data-volume-attachment" {
  count                              = var.gs3_profile != null && var.gs3_data_volume_size != "10" ? var.gs3_count : 0
  instance                           = ibm_is_instance.gs3[count.index].id
  name                               = "${var.vpc}-gs3-${count.index}-data-volume-attachment"
  tags                               = var.tags
  profile                            = "10iops-tier"
  capacity                           = var.gs3_data_volume_size
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
  volume_name                        = "${var.vpc}-gs3-${count.index}-data-volume"
}

