variable "enable_github_actions_oidc" {
  description = "Whether to create GitHub Actions OIDC provider + IAM role for CI/CD."
  type        = bool
  default     = false
}

variable "github_repo_full_name" {
  description = "GitHub repo in the form <owner>/<repo> used in OIDC subject conditions."
  type        = string
  default     = "KnobleChipmunk/terraform-sandbox"
}

variable "github_ref" {
  description = "Git ref allowed to assume the role (e.g., refs/heads/main)."
  type        = string
  default     = "refs/heads/main"
}

variable "github_environment" {
  description = "GitHub Actions Environment name allowed to assume the role (e.g., sandbox). If set, jobs that declare environment:<name> can assume the role."
  type        = string
  default     = "sandbox"
}

variable "github_actions_role_name" {
  description = "IAM role name to be assumed by GitHub Actions via OIDC."
  type        = string
  default     = "terraform-sandbox-github-actions"
}

variable "backend_name_prefix" {
  description = "Name prefix used by infra/bootstrap/backend to create the state bucket/table."
  type        = string
  default     = "terraform-sandbox"
}
