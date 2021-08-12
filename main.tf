provider "google" {
    version = "3.69.0"
    project = "ce-shubham-kadam-304313"
    region = "us-central1"

}

resource "google_compute_subnetwork" "public-subnetwork1" {
    name = "subnet-a"
    ip_cidr_range = "10.0.1.0/24"
    region = "us-central1"
    network = google_compute_network.vpc_network.name
}

resource "google_compute_subnetwork" "public-subnetwork2" {
    name = "subnet-b"x`
    ip_cidr_range = "10.0.2.0/24"
    region = "us-central1"
    network = google_compute_network.vpc_network.name
}

resource "google_compute_network" "vpc_network" {
    name = "terraform-vpc-network"
    auto_create_subnetworks = false
    
}

resource "google_compute_firewall" "firewall-1" {
  name    = "traffic-from-subnet-a"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22","8006"]
  }
  source_ranges = ["10.0.1.0/24"] 

}

resource "google_compute_firewall" "firewall-2" {
  name    = "traffic-from-internet"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"] 

}



resource "google_compute_instance" "terraform1" {
  project      = "ce-shubham-kadam-304313"
  name         = "terraform-machine-1"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = "subnet-a"
    access_config {
    }
  }
  
  depends_on = [google_compute_subnetwork.public-subnetwork1]
}

resource "google_compute_instance" "terraform2" {
  project      = "ce-shubham-kadam-304313"
  name         = "terraform-machine-2"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  
  metadata_startup_script = "#!/bin/sh; sudo apt update -y && sudo apt upgrade -y; sudo apt install mysql-server -y; sed -i '/port = 3306/c\port = 8006' /etc/mysql/mariadb.conf.d/50-server.cnf; sudo service mysql restart"

  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = "subnet-b"
    access_config {
    }
  }
  
  depends_on = [google_compute_subnetwork.public-subnetwork2]
}