terraform {
  required_providers {
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

resource "null_resource" "build_and_run" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cd ../app && docker build -t flask-app:latest . && docker stop flask-app || true && docker rm flask-app || true && docker run -d -p 8000:5000 --name flask-app flask-app:latest"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "docker stop flask-app || true && docker rm flask-app || true"
  }
}

resource "local_file" "deployment_info" {
  filename = "../deployment-info.txt"
  content  = <<EOT
Application deployed successfully!
URL: http://localhost:8000
Health check: http://localhost:8000/health
Container: flask-app
Deployment time: ${timestamp()}
EOT

  depends_on = [null_resource.build_and_run]
}

output "application_url" {
  value = "http://localhost:8000"
}
