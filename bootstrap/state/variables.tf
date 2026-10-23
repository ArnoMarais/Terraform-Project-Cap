variable "region" {
  description = "AWS region that hosts the state buckets"
  type        = string
  default     = "af-south-1"
}

variable "prefix" {
  description = "Owner prefix in the form <surname>-<first_initial>"
  type        = string
}

