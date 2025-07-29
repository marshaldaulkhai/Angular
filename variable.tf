variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure location"
  type        = string
  default     = "East US" # optional default value
}

variable "web_app_name" {
  description = "The name for the web app"
  type        = string
}
