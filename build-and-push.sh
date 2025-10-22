#!/bin/bash

# Script para buildar e subir imagem Docker ao Docker Hub
# Uso: ./build-and-push.sh [tag]

set -e

# Configurações - ALTERE PARA SEU NOME DE USUÁRIO DO DOCKER HUB
DOCKER_USERNAME="victorhugokawano123"
IMAGE_NAME="sinal_ninja_api"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME"
TAG=${1:-"latest"}

echo "🐳 Buildando imagem Docker: $FULL_IMAGE_NAME:$TAG"

# Build da imagem
docker build -t $FULL_IMAGE_NAME:$TAG .

echo "🏷️  Tagueando imagem para Docker Hub"
# A tag já foi aplicada no build, mas vamos garantir
docker tag $FULL_IMAGE_NAME:$TAG $FULL_IMAGE_NAME:$TAG

echo "🔐 Verificando se você está logado no Docker Hub..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Você não está logado no Docker Hub!"
    echo "Execute: docker login"
    exit 1
fi

echo "📤 Fazendo push da imagem..."
docker push $FULL_IMAGE_NAME:$TAG

echo "✅ Imagem enviada com sucesso!"
echo "� URL da imagem: https://hub.docker.com/r/$FULL_IMAGE_NAME"
echo ""
echo "� Para usar a imagem:"
echo "   docker pull $FULL_IMAGE_NAME:$TAG"