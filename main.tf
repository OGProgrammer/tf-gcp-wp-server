# Static IP
resource "google_compute_address" "main" {
  name = "tf-${var.vendor}-wp-${var.server-tag}"
}

# Single Instance + Debian 9 Bash Provision script
resource "google_compute_instance" "main" {
  name = "tf-${var.vendor}-wp-${var.server-tag}"
  machine_type = "${var.machine-type}"
  zone = "${var.region}-${var.zone}"
  deletion_protection = "${var.protect-from-deletion}"

  boot_disk {
    auto_delete = "false"
    initialize_params {
      image = "debian-cloud/debian-9"
      size = "30"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork}"

    # Attach global static IP address to instance
    access_config = {
      nat_ip = "${google_compute_address.main.address}"
    }
  }

  tags = [
    "wp-server",
    "https-server",
    "http-server",
    "ssh",
    "pingable"
  ]

  metadata {
    env = "${var.env}"
    company = "${var.vendor}"
    label = "wp-${var.server-tag}"
    server = "tf-${var.vendor}-wp-${var.server-tag}"
    managedBy = "terraform"
  }

  labels {
    env = "${var.env}"
    company = "${var.vendor}"
    label = "wp-${var.server-tag}"
    server = "tf-${var.vendor}-wp-${var.server-tag}"
    managed_by = "terraform"
  }

  ## Pipe the server setup bash script into the GCP server init script
  metadata_startup_script = "${file("wp-server-deb9.sh")}"
  # If changes are made to the server bash provision script, lets not recreate the server over that.
  lifecycle {
    ignore_changes = ["metadata_startup_script"]
  }
}