output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID de la VPC principal"
}

output "sitio_web_url" {
  value       = aws_s3_bucket_website_configuration.web_config.website_endpoint
  description = "URL publica para acceder a la pagina web"
}