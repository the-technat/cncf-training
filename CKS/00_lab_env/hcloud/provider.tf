provider "hcloud" {
    version = "1.50.0"
    # expects HCLOUD_TOKEN env var
}

provider "hetznerdns" {
    version = "2.2.0"
    # expects HETZNER_DNS_TOKEN env var
}
