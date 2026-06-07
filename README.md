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

http://localhost:8080

# NOTA

El DNS del ALB se incluye únicamente como evidencia del despliegue realizado. Los recursos fueron eliminados posteriormente siguiendo las instrucciones del laboratorio para evitar costos.
