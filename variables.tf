variable "app_name" {
    description = "application name"
    default = "golang-serverless-api"
}

variable "app_env" {
  default = "dev"
  description = "application environment variable"
}

variable "app_runtime" {
  default = "provided.al2"
  description = "lambda runtime specification"
}
