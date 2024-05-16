output "gs1_ip" {
  description = "Primary IP of gs1"
  value       = ibm_is_instance.gs1[*].primary_network_interface[0].primary_ip[0].address
}

output "gs2_ip" {
  description = "Primary IP of gs2"
  value       = ibm_is_instance.gs2[*].primary_network_interface[0].primary_ip[0].address
}

output "gs3_ip" {
  description = "Primary IP of gs3"
  value       = ibm_is_instance.gs3[*].primary_network_interface[0].primary_ip[0].address
}

