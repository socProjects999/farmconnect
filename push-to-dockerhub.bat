@echo off

REM Configuration

SET DOCKER_USERNAME=socprojects999

SET VERSION=latest

echo Building images...

docker-compose build

echo Tagging images...

docker tag farmconnect-user-service:latest %DOCKER_USERNAME%/farmconnect-user-service:%VERSION%

docker tag farmconnect-product-service:latest %DOCKER_USERNAME%/farmconnect-product-service:%VERSION%

docker tag farmconnect-order-service:latest %DOCKER_USERNAME%/farmconnect-order-service:%VERSION%

docker tag farmconnect-admin-service:latest %DOCKER_USERNAME%/farmconnect-admin-service:%VERSION%

docker tag farmconnect-frontend:latest %DOCKER_USERNAME%/farmconnect-frontend:%VERSION%

echo Pushing images to Docker Hub...

docker push %DOCKER_USERNAME%/farmconnect-user-service:%VERSION%

docker push %DOCKER_USERNAME%/farmconnect-product-service:%VERSION%

docker push %DOCKER_USERNAME%/farmconnect-order-service:%VERSION%

docker push %DOCKER_USERNAME%/farmconnect-admin-service:%VERSION%

docker push %DOCKER_USERNAME%/farmconnect-frontend:%VERSION%

echo All images pushed successfully!

pause