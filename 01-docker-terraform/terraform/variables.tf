variable "credentials" {
  description = "JSON "
  default     = "./keys/lyrical-compass-412311-fb227e1cc086.json"
  sensitive   = true
}

variable "my_project" {
  description = "Project name as in GCP"
  type        = string
  default     = "lyrical-compass-412311"
}
