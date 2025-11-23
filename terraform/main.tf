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

resource "google_compute_instance" "vm_ansible_test" {
  count        = 3 
  name         = "vm-${count.index}"
  machine_type = "e2-micro" 
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2210-kinetic-amd64-v20230126"
      size  = 10 
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral IP
    }
  }
  
  # Optionnel : Pour payer encore moins cher si vous sortez du cadre gratuit
  scheduling {
    preemptible = true
    automatic_restart = false
  }
}