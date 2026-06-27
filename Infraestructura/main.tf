# VPC y Subred 
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-subnet-public"
    Environment = var.environment
  }
}

# Grupo de Seguridad con mínimo privilegio 
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-web-sg"
  description = "Permitir trafico HTTP entrante para la pagina web"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP de cualquier lugar"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permitir salida total"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-security-group"
    Environment = var.environment
  }
}

#Almacenamiento S3 para Sitio Web Estático
resource "aws_s3_bucket" "datos" {
  bucket        = "${var.project}-sitio-web-10"
  force_destroy = true # Esencial para que el comando 'destroy' funcione sin residuos [cite: 182]

  tags = {
    Name        = "${var.project}-bucket-web"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "web_config" {
  bucket = aws_s3_bucket.datos.id
  index_document {
    suffix = "index.html"
  }
}

# Desbloquear el acceso público al bucket
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.datos.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket     = aws_s3_bucket.datos.id
  depends_on = [aws_s3_bucket_public_access_block.public_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.datos.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.datos.id
  key          = "index.html"
  source       = "../sitioWeb/index.html"
  content_type = "text/html"
}