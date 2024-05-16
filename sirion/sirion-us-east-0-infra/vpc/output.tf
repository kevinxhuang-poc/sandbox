output "bh1_public_ip" {
  description = "Public IP of jump host 1"
  value       = ibm_is_floating_ip.fip1.address
}

output "bh2_public_ip" {
  description = "Public IP of jump host 2"
  value       = ibm_is_floating_ip.fip2.address
}

output "adm1_primary_ip" {
  description = "Primary IP of adm1"
  value       = ibm_is_instance.adm1[0].primary_network_interface[0].primary_ip[0].address
}

