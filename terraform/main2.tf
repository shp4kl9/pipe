terraform {
  required_providers {
    # Используем встроенные провайдеры
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

# Вместо Docker будем использовать local-exec
resource "null_resource" "build_and_run" {
  triggers = {
    dockerfile_hash = filemd5("../app/Dockerfile")
    app_code_hash   = filemd5("../app/app.py")
  }

  provisioner "local-exec" {
    command = "./deploy.sh"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "(docker stop flask-app || true) && (docker rm flask-app || true)"
  }
}




resource "local_file" "deployment_info" {
  filename = "../deployment-info.txt"
  content  = <<EOT
Application deployed with local-exec!
URL: http://localhost:8000
Health check: http://localhost:8000/health
Deployment time: ${timestamp()}
EOT

  depends_on = [null_resource.build_and_run]
}

output "application_url" {
  value = "http://localhost:8000"
}
