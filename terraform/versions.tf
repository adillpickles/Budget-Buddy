terraform {
  required_version = ">= 1.6.0"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 4.0"
    }
  }

  cloud {
    workspaces {
      name = "budget-buddy-vercel-prod"
    }
  }
}
