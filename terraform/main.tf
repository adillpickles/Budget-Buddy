locals {
  vercel_team_id = var.vercel_team_id == "" ? null : var.vercel_team_id
}

resource "vercel_project" "budget_buddy" {
  name           = var.vercel_project_name
  framework      = "nextjs"
  root_directory = var.root_directory
  team_id        = local.vercel_team_id

  git_repository = {
    type              = "github"
    repo              = var.github_repository
    production_branch = var.production_branch
  }
}
