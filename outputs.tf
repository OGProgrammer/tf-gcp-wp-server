output "server_name" {
  value = "${google_compute_instance.main.name}"
}

output "server_ip" {
  value = "${google_compute_address.main.address}"
}

output "server_internal_ip" {
  value = "${google_compute_instance.main.network_interface.0.access_config.0.nat_ip}"
}

output "server_location" {
  value = "${google_compute_instance.main.zone}"
}