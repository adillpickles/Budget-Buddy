# Session 11 Cloud Deployment and Infrastructure as Code

BudgetBuddy uses Vercel as the public cloud Platform as a Service for the Next.js application and Supabase as the managed auth/database provider. The assignment's AWS Elastic Beanstalk flow is an example; this project uses the equivalent cloud-native workflow for a Next.js app.

## Rubric Mapping

| Rubric category | Implementation |
| --- | --- |
| Configure a public cloud provider | Vercel project configuration is defined in `terraform/` using the official Vercel Terraform provider. |
| Automate infrastructure deployment | `.github/workflows/terraform.yml` runs secret-free Terraform fmt, backendless init, and validate checks on pull requests; trusted pushes to `main` run remote-state plan and apply with HCP Terraform. |
| Automate application deployment | `.github/workflows/cd.yml` builds the Next.js app with Vercel CLI and deploys the prebuilt production artifact to Vercel after App CI succeeds. |
| Create a PR with changes | This branch contains the Terraform, GitHub Actions, and documentation changes needed for review and submission. |

## Cloud Architecture

- `nextjs/`: Next.js application deployed to Vercel.
- Vercel: public PaaS hosting, build, deployment, routing, serverless execution, and production/preview environments.
- Supabase: hosted PostgreSQL and authentication.
- GitHub Actions: CI, Supabase migration automation, Terraform infrastructure automation, and Vercel application deployment.
- HCP Terraform: persistent Terraform state and locking for Vercel infrastructure.

## Terraform State Strategy

The Terraform configuration uses an HCP Terraform `cloud` block instead of local state. This mirrors the assignment PDF's emphasis on remote Terraform state in the AWS example while avoiding AWS infrastructure that BudgetBuddy does not otherwise need.

Ephemeral state in GitHub Actions is intentionally avoided because it would not remember existing Vercel resources between workflow runs. Persistent remote state makes the infrastructure workflow reviewable, repeatable, and safer for full-credit infrastructure automation.

## Workflow Secret Behavior

Fork and untrusted pull requests usually do not receive GitHub repository secrets. The workflows are structured around that limitation:

- `.github/workflows/terraform.yml` runs `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate` on pull requests without requiring cloud credentials.
- Terraform remote-state `plan` runs only outside pull requests, such as pushes to `main` or manual `workflow_dispatch`, and requires `TF_API_TOKEN`, `VERCEL_API_TOKEN`, and `TF_CLOUD_ORGANIZATION`.
- Terraform `apply` runs only on trusted pushes to `main`; manual `workflow_dispatch` validates and plans but does not apply changes.
- `.github/workflows/cd.yml` does not run on pull requests. It runs after App CI succeeds on `main`, or by manual `workflow_dispatch`, and requires Vercel and Supabase deployment secrets.
- If a trusted workflow is missing secrets, it fails early with a clear missing-input message rather than failing later inside Vercel or Terraform.

## What Terraform Manages

Terraform manages safe Vercel project infrastructure:

- project name
- Next.js framework selection
- GitHub repository linkage
- production branch
- root directory for the app

Terraform does not manage runtime secret values. Supabase and database secrets should remain in GitHub Actions secrets and Vercel environment variables so they are not written into Terraform state.

## Required GitHub Secrets and Variables

Secrets:

- `TF_API_TOKEN`: HCP Terraform API token.
- `VERCEL_API_TOKEN`: Vercel API token for Terraform infrastructure management.
- `VERCEL_TOKEN`: Vercel CLI token for application deployment.
- `VERCEL_ORG_ID`: Vercel org/user id for CLI deployment.
- `VERCEL_PROJECT_ID`: Vercel project id for CLI deployment.
- `SUPABASE_URL`: Supabase project URL.
- `SUPABASE_ANON_KEY`: Supabase anonymous API key.
- `DATABASE_URL`: Supabase Postgres connection string.
- `SUPABASE_SERVICE_ROLE_KEY`: service role key used by CI test seeding, if test seeding remains enabled.

Repository variables:

- `TF_CLOUD_ORGANIZATION`: HCP Terraform organization name.
- `VERCEL_TEAM_ID`: optional Vercel team id; leave unset for a personal Vercel account.

## Manual Setup

1. Create an HCP Terraform organization and a workspace named `budget-buddy-vercel-prod`.
2. Set the HCP Terraform workspace execution mode to **Local**. GitHub Actions runs Terraform, and HCP Terraform stores the remote state and handles state locking.
3. Add the GitHub secrets and repository variables listed above.
4. Create or confirm the Vercel project that hosts BudgetBuddy.
5. Confirm the Vercel GitHub integration has access to `adillpickles/Budget-Buddy`.
6. Confirm the Vercel project has Production and Preview environment variables for `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `DATABASE_URL`.
7. In Supabase Auth URL settings, set the Site URL to the deployed Vercel app URL.
8. In Supabase Auth redirect URLs, add `https://YOUR_DEPLOYED_DOMAIN/reset-password`.
9. Keep `http://localhost:3000/reset-password` as an allowed redirect URL for local development if needed.
10. Do not automate Supabase auth URL configuration through Terraform for this assignment; this repo does not currently have a safe Supabase provider setup for that.
11. If the Vercel project already exists, import it before the first Terraform apply:

```bash
cd terraform
export TF_CLOUD_ORGANIZATION=<hcp-terraform-org>
terraform init
terraform import vercel_project.budget_buddy <vercel-project-id>
terraform plan
```

For a team-owned project, use:

```bash
terraform import vercel_project.budget_buddy <team-id>/<vercel-project-id>
```

## Validation Commands

Run app validation from the repository root:

```bash
cd nextjs
npm ci
npm test -- --coverage
npm run build
```

Run infrastructure validation after Terraform and HCP Terraform are configured:

```bash
cd terraform
terraform fmt -check
terraform init
terraform validate
terraform plan
```

For fork/untrusted PR-style validation without secrets:

```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

After deployment, verify the production app and health endpoint:

```bash
curl https://<production-domain>/api/health
```
