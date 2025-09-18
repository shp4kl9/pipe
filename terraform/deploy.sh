#!/bin/bash
cd ../app
docker build -t flask-app:latest
docker stop flask-app || true
docker rm flask-app || true
docker run -d -p 8000:5000 --name flask-app flask-app:latest
