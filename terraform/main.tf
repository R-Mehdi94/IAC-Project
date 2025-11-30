terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "terraform-esgi"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "staging_web" {
  count        = 2
  name         = "staging-web-${count.index + 1}" # Donnera staging-web-1, staging-web-2
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags = ["web"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }
  network_interface {
    network = "default"
    access_config {} # Permet d'avoir une IP publique
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_instance" "staging_db" {
  count        = 1
  name         = "staging-db-1"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags = ["db"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# --- PROD ---

resource "google_compute_instance" "prod_web" {
  count        = 3
  name         = "prod-web-${count.index + 1}"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags = ["web"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_instance" "prod_db" {
  count        = 1
  name         = "prod-db-1"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags = ["db"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


#ressource pour générer le fichier d'inventaire Ansible avec les adresses IP de chaque instance
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tftpl", {
    # On récupère les IPs de chaque groupe
    staging_web_ips = google_compute_instance.staging_web[*].network_interface.0.access_config.0.nat_ip
    staging_db_ips  = google_compute_instance.staging_db[*].network_interface.0.access_config.0.nat_ip
    prod_web_ips    = google_compute_instance.prod_web[*].network_interface.0.access_config.0.nat_ip
    prod_db_ips     = google_compute_instance.prod_db[*].network_interface.0.access_config.0.nat_ip
  })
  filename = "${path.module}/../inventory.ini"

}



resource "google_compute_firewall" "rules" {
  name        = "my-firewall-rule"
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["80", "443","81"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_firewall" "allow_mysql" {
  name    = "allow-mysql"
  network = "default"
  description = "Allow MySQL connections from web servers"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_tags = ["web"]
  target_tags = ["db"]
}
