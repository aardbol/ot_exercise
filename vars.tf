variable "do_token" {
  description = "Digitalocean API token"
}

variable "node_regions" {
  type    = list(string)
  default = ["ams2", "fra1", "nyc1", "tor1", "sfo2"]
}

variable "ssh_pubkeys" {
  type = map(string)
}