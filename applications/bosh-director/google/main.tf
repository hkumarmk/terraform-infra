terraform {
  backend "consul" {}
}

# credentials to be accessed from GOOGLE_CREDENTIALS environment variable
provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}

# Read data from base_networking
data "terraform_remote_state" "base_networking" {
  backend = "consul"
  config = {
    address = "${var.tf_consul_address}"
    path = "${var.tf_base_networking_state_path}"
  }
}

module "firewall" {
  source      = "../../../modules/google/firewall"
  rules    = "${var.firewall_rules}"
  vpc_id = "${data.terraform_remote_state.base_networking.vpc_id}"
}

resource "google_compute_instance_group" "bosh" {
  name = "bosh"
  zone = "${var.zone}"
  description = "BOSH instance group"
  network = "${data.terraform_remote_state.base_networking.vpc_link}"
  named_port {
    name = "https"
    port = 443
  }
}

// Subnet for the BOSH director
resource "google_compute_subnetwork" "bosh-subnet" {
  name          = "subnet-bosh-${var.region}"
  ip_cidr_range = "${var.subnet}"
  network       = "${data.terraform_remote_state.base_networking.vpc_link}"
}


# Route to nat node
resource "google_compute_route" "nat-primary" {
  count   = "${var.jumpbox ? 1 : 0}"
  name                   = "bosh-nat-primary"
  dest_range             = "0.0.0.0/0"
  network                = "${data.terraform_remote_state.base_networking.vpc_id}"
  next_hop_instance      = "${google_compute_instance.bosh-bastion.name}"
  next_hop_instance_zone = "${var.zone}"
  priority               = 800
  tags                   = ["no-ip"]
}

// BOSH bastion host
resource "google_compute_instance" "bosh-bastion" {
  count   = "${var.jumpbox ? 1 : 0}"
  name         = "${var.prefix}bosh-bastion"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  tags = ["bosh-bastion", "internal"]

  boot_disk {
    initialize_params {
      image = "${var.latest_ubuntu}"
    }
  }

  network_interface {
    subnetwork         = "${google_compute_subnetwork.bosh-subnet.name}"
    access_config {}
  }

  metadata_startup_script = <<EOT
#!/bin/bash
cat > /etc/motd <<EOF
#    #     ##     #####    #    #   #   #    #    ####
#    #    #  #    #    #   ##   #   #   ##   #   #    #
#    #   #    #   #    #   # #  #   #   # #  #   #
# ## #   ######   #####    #  # #   #   #  # #   #  ###
##  ##   #    #   #   #    #   ##   #   #   ##   #    #
#    #   #    #   #    #   #    #   #   #    #    ####
Startup scripts have not finished running, and the tools you need
are not ready yet. Please log out and log back in again in a few moments.
This warning will not appear when the system is ready.
EOF
apt-get update
apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 git unzip
gem install bosh_cli
curl -L -o /tmp/cf.tgz "https://cli.run.pivotal.io/stable?release=linux64-binary&version=6.28.0&source=github-rel"
tar -zxvf /tmp/cf.tgz && mv cf /usr/bin/cf && chmod +x /usr/bin/cf
curl -o /usr/bin/bosh-init https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.96-linux-amd64
chmod +x /usr/bin/bosh-init
curl -o /usr/bin/bosh2 https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.28-linux-amd64
chmod +x /usr/bin/bosh2
curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x /usr/bin/jq
cat > /etc/profile.d/bosh.sh <<'EOF'
#!/bin/bash
# Misc vars
export prefix=${var.prefix}
export ssh_key_path=$HOME/.ssh/bosh
# Vars from Terraform
export subnetwork=${google_compute_subnetwork.bosh-subnet.name}
export network=${data.terraform_remote_state.base_networking.vpc_id}
export network_project_id=${var.project}
# Vars from metadata service
export project_id=$$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
export zone=$$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone)
export zone=$${zone##*/}
export region=$${zone%-*}
# Configure gcloud
gcloud config set compute/zone $${zone}
gcloud config set compute/region $${region}
EOF
# Clone repo
mkdir /share
git clone https://github.com/cloudfoundry-incubator/bosh-google-cpi-release.git /share
chmod -R 777 /share
# Install Terraform
wget https://releases.hashicorp.com/terraform/0.7.7/terraform_0.7.7_linux_amd64.zip
unzip terraform*.zip -d /usr/local/bin
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -t nat -A POSTROUTING -o $(ip r l | grep default | awk "{print \$NF}") -j MASQUERADE
rm /etc/motd
EOT
  can_ip_forward = true
}
