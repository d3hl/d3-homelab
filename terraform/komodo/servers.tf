
# ─── Git credentials ─────────────────────────────────────────────────────────
# komodo_provider_account registers a GitHub personal access token (PAT) with
# Komodo so it can authenticate against github.com for every clone and pull.
resource "komodo_provider_account" "github" {
  domain        = "github.com"
  https_enabled = true
  username      = "d3hl"
  token         = var.github_token
}

# ─── Tag ─────────────────────────────────────────────────────────────────────
# Tags let you group and filter resources in the Komodo UI.
resource "komodo_tag" "app" {
  name  = "my-app"
  color = "Indigo"
}

# ─── Repository ──────────────────────────────────────────────────────────────
# Registering the repo gives Komodo a named handle for cloning, pulling, and
# triggering builds or deploys via webhooks.
resource "komodo_repo" "app" {
  name      = "my-app"
  server_id = var.server_id
  links     = [komodo_tag.app.id]

  source {
    path       = "myorg/my-app"   # <owner>/<repo> on GitHub
    branch     = "main"
    account_id = komodo_provider_account.github.id
  }
}

# ─── Stack ───────────────────────────────────────────────────────────────────
# The stack sources its compose file from the repository registered above.
# Using repo_id delegates authentication and clone details to the komodo_repo
# resource — no need to repeat provider account credentials here.
resource "komodo_stack" "app" {
  name      = "my-app"
  server_id = var.server_id
  links     = [komodo_tag.app.id]

  source {
    repo_id = komodo_repo.app.id
    path    = "docker-compose.yml"
    branch  = "main"
  }

  environment {
    variables = {
      APP_ENV  = "production"
      APP_PORT = "8080"
    }
  }

  auto_pull_enabled = true
}