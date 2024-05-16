variable "vpc" {
  description = "The name of the VPC"
  type        = string
}

variable "tags" {
  type    = list(any)
  default = []
}

variable "classic_access" {
  description = "Enable private network connectivity from VPC to classic infrastructure resources"
  type        = bool
  default     = false
}

variable "keys" {
  description = "The list of VPC SSH Key names"
  type        = list(string)
}

variable "resource_group" {
  description = "The name of the Resource Group"
  type        = string
  default     = "Default"
}

variable "region" {
  description = "The name of the Region"
  type        = string
  default     = "us-east"
}

variable "zones" {
  description = "The VPC zones"
  type        = map(any)
  default = {
    "zone1" = "us-east-1"
    "zone2" = "us-east-2"
    "zone3" = "us-east-3"
  }
}

variable "subnets" {
  description = "The subnets"
  type        = map(any)
  default = {
    "subnet1" = "10.1.1.0/24"
    "subnet2" = "10.1.2.0/24"
    "subnet3" = "10.1.3.0/24"
  }
}

variable "jh_image" {
  description = "OS image for Jump Hosts"
  type        = string
  default     = "ibm-ubuntu-22-04-4-minimal-amd64-1"
}

variable "jh_profile" {
  description = "VPC VSI profile name for Jump Hosts"
  type        = string
  default     = "cx2-2x4"
}

variable "adm1_image" {
  description = "OS image for admin server 1"
  type        = string
  default     = "ibm-ubuntu-22-04-4-minimal-amd64-1"
}

variable "adm1_profile" {
  description = "VPC VSI profile name for admin server 1"
  type        = string
  default     = "bx2-4x16"
}

variable "adm1_zone" {
  description = "VPC zone for admin server 1"
  type        = string
}

variable "adm1_subnet" {
  description = "VPC subnet for admin server 1"
  type        = string
}

variable "adm1_data_volume_size" {
  description = "The size of the data volume of admin server 1 in GB"
  type        = string
  default     = "10"
}

