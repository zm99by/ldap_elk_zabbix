// ssh variables
variable "ssh_user" {
    type        = string
    default     = "centos"
    description = "ssh user name"
}

variable "ssh_key" {
    type        = string
    default     = "~/.ssh/id_rsa.pub"
    description = "ssh user key"
}
// public variable
variable "project" {
    type        = string
    default     = "vladimir-project-01"
    description = "project name"
}

variable "region" {
    type        = string
    default     = "us-central1"
    description = "project region"
}

variable "zone" {
    type        = string
    default     = "us-central1-c"
    description = "project zone"
}
variable "name" {
    type        = string
    default     = "vsahonchik"
    description = "student name"
}

variable "vpc_ldap_auto_subnetworks" {
    type        = bool
    default     = false
    description = "auto creating of default subnetworks for vpc_ldap"
}

variable "subnetwork_ldap_ip_cidr_range" {
    type        = string
    default     = "10.13.1.0/24"
    description = "ip range for public subnetwork"
}

variable "wm_machine_type" {
    type        = string
    default     = "custom-1-4608"
    description = "custom machine type for virtual machine"
}

variable "wm_tags" {
    type        = list
    default     = ["wm"]
    description = "virtual machine tags"
}

variable "wm_image" {
    type        = string
    default     = "centos-cloud/centos-7"
    description = "image for creating virtual machine"
}

variable "firewall_ldap_server_protocol" {
    type        = string
    default     = "tcp"
    description = "firewall protocol"
}

variable "firewall_ldap_server_ports" {
    type        = list
    default     = ["22", "80", "389"]
    description = "firewall port"
}

variable "firewall_ldap_server_source_ranges" {
    type = list
    default = ["0.0.0.0/0"]
    description = "source range from the Internet to virtual machine"
}