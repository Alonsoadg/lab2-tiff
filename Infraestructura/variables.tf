variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Región de AWS"
}

variable "project" {
  type        = string
  default     = "lab2-tiff"
  description = "Prefijo para identificar los recursos en AWS y mantener consistencia."
}

variable "environment" {
  type        = string
  default     = "desarrollo"
  description = "Ambiente de ejecución para aplicar en los tags."
}