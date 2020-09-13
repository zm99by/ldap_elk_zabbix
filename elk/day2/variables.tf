variable project {
   default = "vladimir-project-01"
   description = "project name"
}
variable region {
   default = "us-central1"
   description = "region name"
}
variable zone {
   default = "us-central1-c"
   description = "zone name"
}
variable name {
    default = "elk"
    description = "name"
}
variable student_IDnum {
    default = "13"
}
variable image {
    default = "centos-cloud/centos-7"
}
variable size {
    default = "20"
}
variable disk_type {
    default = "pd-ssd"
}
variable user {
    default = "centos"
}
variable ssh_key {
    default = "id_rsa.pub"
}
variable "script" {
    default = "script.sh"
}