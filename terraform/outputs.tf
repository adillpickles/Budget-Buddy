output "vercel_project_id" {
  description = "Vercel project id managed by Terraform."
  value       = vercel_project.budget_buddy.id
}

output "vercel_project_name" {
  description = "Vercel project name managed by Terraform."
  value       = vercel_project.budget_buddy.name
}

output "vercel_root_directory" {
  description = "Repository directory Vercel builds from."
  value       = vercel_project.budget_buddy.root_directory
}
