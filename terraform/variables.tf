variable "vercel_project_name" {
  description = "Name of the Vercel project that hosts BudgetBuddy."
  type        = string
  default     = "budget-buddy"
}

variable "github_repository" {
  description = "GitHub repository connected to the Vercel project."
  type        = string
  default     = "adillpickles/Budget-Buddy"
}

variable "production_branch" {
  description = "Git branch Vercel should treat as production."
  type        = string
  default     = "main"
}

variable "root_directory" {
  description = "Directory containing the Next.js application within the repository."
  type        = string
  default     = "nextjs"
}

variable "vercel_team_id" {
  description = "Optional Vercel team id. Leave empty for a personal Vercel account."
  type        = string
  default     = ""
}
