variable "project" {
  type    = string
  default = "vladimir-project-01"
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