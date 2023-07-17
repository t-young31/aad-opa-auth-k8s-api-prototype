variable "azure_suffix" {
  type        = string
  description = "Suffix used for naming resources"
}

variable "acr_name" {
  type = string
  description = "Name of the Azure Container Registry (ACR) to create"
}

variable "domain_label" {
  type = string
  description = "Domain to use for the public IP. FQDN will be e.g. <domain_label>.uksouth..cloudapp.azure.com"
}
