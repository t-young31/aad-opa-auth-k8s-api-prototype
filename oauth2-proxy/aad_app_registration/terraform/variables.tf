variable "app_name" {
  type = string
  description = "Name of the app registration to create in Azure AD"
}

variable "redirect_url" {
  type = string
  description = "URL for callback after authentication e.g. https://localhost:8000/oauth2/callback"
}
