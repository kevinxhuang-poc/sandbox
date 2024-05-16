variable "vpc" {
  description = "The name of the VPC"
  type        = string
}

variable "tags" {
  type    = list(any)
  default = []
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

variable "gs1_image" {
  description = "OS image for GPU servers - gs1"
  type        = string
}

variable "gs1_profile" {
  description = "VPC VSI profile name for GPU servers - gs1"
  type        = string
  default     = null
}

variable "gs1_zone" {
  description = "VPC zone for GPU servers - gs1"
  type        = string
}

variable "gs1_subnet" {
  description = "VPC subnet for GPU servers - gs1"
  type        = string
}

variable "gs1_data_volume_size" {
  description = "The size of the data volume in GB for GPU servers - gs1"
  type        = string
  default     = "10"
}

variable "gs1_count" {
  description = "The number of GPU servers - gs1"
  type        = string
  default     = "0"
}

variable "gs2_image" {
  description = "OS image for GPU servers - gs2"
  type        = string
}

variable "gs2_profile" {
  description = "VPC VSI profile name for GPU servers - gs2"
  type        = string
  default     = null
}

variable "gs2_zone" {
  description = "VPC zone for GPU servers - gs2"
  type        = string
}

variable "gs2_subnet" {
  description = "VPC subnet for GPU servers - gs2"
  type        = string
}

variable "gs2_data_volume_size" {
  description = "The size of the data volume in GB for GPU servers - gs2"
  type        = string
  default     = "10"
}

variable "gs2_count" {
  description = "The number of GPU servers - gs2"
  type        = string
  default     = "0"
}

variable "gs3_image" {
  description = "OS image for GPU servers - gs3"
  type        = string
}

variable "gs3_profile" {
  description = "VPC VSI profile name for GPU servers - gs3"
  type        = string
  default     = null
}

variable "gs3_zone" {
  description = "VPC zone for GPU servers - gs3"
  type        = string
}

variable "gs3_subnet" {
  description = "VPC subnet for GPU servers - gs3"
  type        = string
}

variable "gs3_data_volume_size" {
  description = "The size of the data volume in GB for GPU servers - gs3"
  type        = string
  default     = "10"
}

variable "gs3_count" {
  description = "The number of GPU servers - gs3"
  type        = string
  default     = "0"
}

