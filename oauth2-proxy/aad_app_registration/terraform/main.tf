resource "azuread_application" "api" {
  display_name     = var.app_name
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  api {
    requested_access_token_version = 2
  }

  web {
    redirect_uris = [var.redirect_url]

    # implicit_grant {
    #   access_token_issuance_enabled = false
    #   id_token_issuance_enabled     = true
    # }
  }

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    dynamic "resource_access" {
      for_each = local.required_graph_permissions
      iterator = permission

      content {
        id   = azuread_service_principal.msgraph.app_role_ids[permission.value]
        type = "Role"
      }
    }
  }
}

resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

resource "azuread_application_password" "api" {
  application_object_id = azuread_application.api.object_id
}

resource "null_resource" "grant_aad_admin_consent" {
  triggers = merge(
    [for app in azuread_application.api.required_resource_access :
      { for role in app.resource_access : "${app.resource_app_id}_${role.id}" => role.type }
    ]
    ...
  )

  # Not possible with terraform so invoke the az cli to grant admin consent
  provisioner "local-exec" {
    command = "sleep 30 && az ad app permission admin-consent --id ${azuread_application.api.application_id}"
  }
}
