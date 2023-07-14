variable "azure_suffix" {
  type        = string
  description = "Suffix used for naming resources"
}

variable "acr_name" {
  type = string
  description = "Name of the Azure Container Registry (ACR) to create"
}
