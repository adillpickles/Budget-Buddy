# BudgetBuddy Terraform Infrastructure

This directory defines the public cloud infrastructure for BudgetBuddy on Vercel. It uses the official Vercel Terraform provider and HCP Terraform remote state so infrastructure changes are persistent, reviewable, and safe to automate from GitHub Actions.

## What Terraform Manages

- Vercel project name and framework.
- GitHub repository connection for `adillpickles/Budget-Buddy`.
- Production branch tracking for `main`.
- Root directory configuration for the Next.js app in `nextjs/`.

Terraform intentionally does not manage Supabase or database runtime secrets. Values such as `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `DATABASE_URL` should stay in GitHub Actions secrets and Vercel project environment variables so they are not written into Terraform configuration or state.

## Required Manual Setup

1. Create an HCP Terraform organization and a workspace named `budget-buddy-vercel-prod`.
2. Set the HCP Terraform workspace execution mode to **Local**. GitHub Actions will execute Terraform, while HCP Terraform stores the remote state and handles state locking.
3. Add a GitHub repository variable named `TF_CLOUD_ORGANIZATION` with the HCP Terraform organization name.
4. Add a GitHub secret named `TF_API_TOKEN` with an HCP Terraform API token that can access the workspace.
5. Add a GitHub secret named `VERCEL_API_TOKEN` with a Vercel token that can manage the target project.
6. If the project belongs to a Vercel team, add a GitHub repository variable named `VERCEL_TEAM_ID`.
7. Confirm the Vercel GitHub integration has access to `adillpickles/Budget-Buddy`.
8. Confirm Vercel project environment variables exist for Production and Preview:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `DATABASE_URL`
9. In Supabase Auth URL settings, set the Site URL to the deployed Vercel app URL.
10. Add `https://YOUR_DEPLOYED_DOMAIN/reset-password` as an allowed Supabase redirect URL.
11. Keep `http://localhost:3000/reset-password` as an allowed redirect URL for local development if needed.

Supabase auth URL configuration is manual for this assignment. Terraform does not manage it because this repo does not currently include a safe Supabase provider setup, and runtime/auth secrets should not be introduced into Terraform state.

## GitHub Actions Behavior

Pull requests run only secret-free static checks: `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate`. This prevents fork or untrusted PRs from failing just because GitHub withholds repository secrets.

Terraform remote-state `plan` runs only for trusted contexts, such as pushes to `main` and manual workflow dispatches. Terraform `apply` runs only on trusted pushes to `main`; manual workflow dispatches validate and plan but do not apply changes. These runs require `TF_API_TOKEN`, `VERCEL_API_TOKEN`, and `TF_CLOUD_ORGANIZATION`.

## Existing Vercel Project Import

If the BudgetBuddy Vercel project already exists, import it before applying this configuration so Terraform adopts the existing project instead of creating a duplicate.

For a personal Vercel account:

```bash
cd terraform
export TF_CLOUD_ORGANIZATION=<hcp-terraform-org>
terraform init
terraform import vercel_project.budget_buddy <vercel-project-id>
```

In PowerShell, set the organization with `$env:TF_CLOUD_ORGANIZATION = "<hcp-terraform-org>"` before running `terraform init`.

For a Vercel team project:

```bash
cd terraform
export TF_CLOUD_ORGANIZATION=<hcp-terraform-org>
terraform init
terraform import vercel_project.budget_buddy <team-id>/<vercel-project-id>
```

After import, run:

```bash
terraform plan
```

Review any differences carefully before applying.

## Local Validation

```bash
cd terraform
terraform fmt -check
terraform init
terraform validate
terraform plan
```

For pull-request-style validation without secrets or remote state access:

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```
