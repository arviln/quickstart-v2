terraform {
  backend "http" {
    address        = "https://api.abbey.io/terraform-http-backend"
    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.3"
    }
  }
}

provider "abbey" {
  # Configuration options
  bearer_auth = var.abbey_token
}

resource "abbey_grant_kit" "abbey_demo_site" {
  name = "Abbey_Demo_Site"
  description = <<-EOT
    Grants access to Abbey's Demo Page.
    This Grant Kit uses a single-step Grant Workflow that requires only a single reviewer
    from a list of reviewers to approve access.
  EOT

  workflow = {
    steps = [
      {
        reviewers = {
          one_of = ["arvil@abbey.so"]
        }
      }
    ]
  }

  policies = [
    { bundle = "github://arviln/quickstart-v2/policies" } # CHANGEME
  ]

  output = {
    # Replace with your own path pointing to where you want your access changes to manifest.
    # Path is an RFC 3986 URI, such as `github://{organization}/{repo}/path/to/file.tf`.
    location = "github://arviln/quickstart-v2/access.tf" 
    append = <<-EOT
      resource "abbey_demo" "grant_read_write_access" {
        permission = "read_write"
        email = "{{ .data.system.abbey.abbey_identity }}"
      }
    EOT
  }
}

resource "abbey_identity" "user_1" {
  name = "User 1"

  linked = jsonencode({
    abbey = [
      {
        type  = "AuthId"
        value = "arvil@abbey.so" # CHANGEME
      }
    ]
  })
}
