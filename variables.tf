# Required vars

variable "subnetwork" {
  description = "Pass a PUBLIC subnetwork into here!"
}

variable "region" {
  description = "GCP region"
}

variable "zone" {
  description = "GCP zone"
}

variable "vendor" {
  description = "A short 2-4 char tag for your corp biz name. Ex. rdf"
}

variable "server-tag" {
  description = "A short 2-4 char tag for this specific server. Ex. wp03"
}

# Optional vars

variable "protect-from-deletion" {
  default = "true"
}

variable "machine-type" {
  default = "n1-standard-1"
}

variable "env" {
  default = "prod"
}
