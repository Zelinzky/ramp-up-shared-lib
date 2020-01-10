variable "bucket_name" {
  description = "The name of the s3 bucket. It must be globally unique."
  type = string
  default = "devops-rampup-rlargot-tfstate"
}

variable "lock_table_name" {
  description = "The name of the dynamoDB table. Must be unique in this aws account."
  type = string
  default = "devops-rampup-rlargot-tflocks"
}

variable "user_tag" {
  description = "tag to relate the resource to the user that created it"
  type = string
  default = "rlargot"
}