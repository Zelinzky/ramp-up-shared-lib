variable "user_tag" {
  description = "tag to relate the resource to the user that created it"
  type = string
  default = "rlargot"
}

variable "project_name" {
  type = string
  default = "rlargot-rampup"
}

variable "custom_server_port" {
  type = number
  default = 3000
}

variable "environment_name" {
  type = string
  default = "staging"
}