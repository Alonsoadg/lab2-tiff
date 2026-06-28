# Laboratorio 2

## Integrantes

- Alonso Duarte
- Joaquin Gonzalez

---

# Nombre del emprendimiento

Café del Sur

## Construcción de la imagen Docker

cd sitioWeb

docker build -t cafe-del-sur:1.0 .

# Ejecución local

docker run --rm -p 8080:80 cafe-del-sur:1.0

# URL

(cafe-del-sur-alb-685753372.us-east-1.elb.amazonaws.com)

# NOTA

El DNS del ALB se incluye únicamente como evidencia del despliegue realizado. Los recursos fueron eliminados posteriormente siguiendo las instrucciones del laboratorio para evitar costos.

# Descripción

Este repositorio contiene la configuración para el despliegue automático del sitio web Café del Sur en AWS, utilizando Terraform como herramienta de Infraestructura como Código (IaC). El proyecto garantiza un ciclo de vida completo mediante el aprovisionamiento automatizado y la limpieza de recursos.
