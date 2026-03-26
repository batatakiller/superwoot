#!/bin/bash

# Coolify Automated Installation Script for Chatwoot (Superwoot)
# This script uses the Coolify API to create a project and deploy services.

set -e

# --- Configuration ---
COOLIFY_API_KEY="7|yE7JaGlicVVUY6fz55IGKKinUfwGiPW29CBP3ORRa7c982f8"
COOLIFY_URL="http://147.15.99.72:8000"
PROJECT_NAME="Chatwoot-Automated"
ENVIRONMENT_NAME="production"
DOCKER_COMPOSE_FILE="docker-compose.coolify.yaml"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Iniciando instalação automatizada no Coolify...${NC}"

# Check for dependencies
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ Erro: 'jq' não está instalado. Por favor, instale-o para continuar.${NC}"
    exit 1
fi

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}❌ Erro: Arquivo $DOCKER_COMPOSE_FILE não encontrado.${NC}"
    exit 1
fi

# 1. Get Servers
echo -e "${YELLOW}📡 Buscando servidores disponíveis...${NC}"
SERVERS_JSON=$(curl -s -X GET "$COOLIFY_URL/api/v1/servers" \
     -H "Authorization: Bearer $COOLIFY_API_KEY" \
     -H "Accept: application/json")

SERVER_UUID=$(echo "$SERVERS_JSON" | jq -r '.[0].uuid')

if [ "$SERVER_UUID" == "null" ] || [ -z "$SERVER_UUID" ]; then
    echo -e "${RED}❌ Erro: Nenhum servidor encontrado no Coolify.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Servidor encontrado: $SERVER_UUID${NC}"

# 2. Create Project
echo -e "${YELLOW}🏗️ Criando projeto: $PROJECT_NAME...${NC}"
PROJECT_JSON=$(curl -s -X POST "$COOLIFY_URL/api/v1/projects" \
     -H "Authorization: Bearer $COOLIFY_API_KEY" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d "{\"name\": \"$PROJECT_NAME\"}")

PROJECT_UUID=$(echo "$PROJECT_JSON" | jq -r '.uuid')
if [ "$PROJECT_UUID" == "null" ] || [ -z "$PROJECT_UUID" ]; then
    # Try to find if it already exists
    echo -e "${YELLOW}⚠️ Projeto já pode existir, tentando localizar...${NC}"
    PROJECT_UUID=$(curl -s -X GET "$COOLIFY_URL/api/v1/projects" \
         -H "Authorization: Bearer $COOLIFY_API_KEY" \
         -H "Accept: application/json" | jq -r ".[] | select(.name == \"$PROJECT_NAME\") | .uuid")
fi

if [ -z "$PROJECT_UUID" ]; then
    echo -e "${RED}❌ Erro ao criar ou localizar projeto.${NC}"
    echo "$PROJECT_JSON"
    exit 1
fi
echo -e "${GREEN}✅ Projeto pronto: $PROJECT_UUID${NC}"

# 3. Create Environment
# Environments are usually created with the project, but we'll ensure production exists
echo -e "${YELLOW}🌐 Configurando ambiente: $ENVIRONMENT_NAME...${NC}"
# Actually, we should check if it exists first
ENV_UUID=$(curl -s -X GET "$COOLIFY_URL/api/v1/projects/$PROJECT_UUID" \
     -H "Authorization: Bearer $COOLIFY_API_KEY" \
     -H "Accept: application/json" | jq -r ".environments[] | select(.name == \"$ENVIRONMENT_NAME\") | .uuid")

if [ -z "$ENV_UUID" ] || [ "$ENV_UUID" == "null" ]; then
    ENV_JSON=$(curl -s -X POST "$COOLIFY_URL/api/v1/projects/$PROJECT_UUID/environments" \
         -H "Authorization: Bearer $COOLIFY_API_KEY" \
         -H "Content-Type: application/json" \
         -H "Accept: application/json" \
         -d "{\"name\": \"$ENVIRONMENT_NAME\"}")
    ENV_UUID=$(echo "$ENV_JSON" | jq -r '.uuid')
fi

echo -e "${GREEN}✅ Ambiente pronto: $ENV_UUID${NC}"

# 4. Create Service (Docker Compose based)
echo -e "${YELLOW}🐳 Criando serviço Docker Compose...${NC}"

# Base64 encode the docker-compose file (required by Coolify API)
COMPOSE_CONTENT=$(cat "$DOCKER_COMPOSE_FILE" | base64 | tr -d '\n')

# Coolify Service Creation API
SERVICE_JSON=$(curl -s -X POST "$COOLIFY_URL/api/v1/services" \
     -H "Authorization: Bearer $COOLIFY_API_KEY" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d "{
       \"project_uuid\": \"$PROJECT_UUID\",
       \"environment_name\": \"$ENVIRONMENT_NAME\",
       \"server_uuid\": \"$SERVER_UUID\",
       \"name\": \"chatwoot-superwoot\",
       \"description\": \"Chatwoot auto-deployed via script\",
       \"docker_compose_raw\": \"$COMPOSE_CONTENT\"
     }")

SERVICE_UUID=$(echo "$SERVICE_JSON" | jq -r '.uuid')

if [ "$SERVICE_UUID" == "null" ] || [ -z "$SERVICE_UUID" ]; then
    echo -e "${RED}❌ Erro ao criar serviço no Coolify.${NC}"
    echo "$SERVICE_JSON"
    exit 1
fi

echo -e "${GREEN}✅ Serviço criado com sucesso! UUID: $SERVICE_UUID${NC}"

# 5. Summary and Next Steps
echo -e "\n${GREEN}===============================================${NC}"
echo -e "${GREEN}🎉 Instalação (Configuração) Concluída!${NC}"
echo -e "O projeto '${PROJECT_NAME}' foi criado no Coolify."
echo -e "Acesse: $COOLIFY_URL/project/$PROJECT_UUID/$ENVIRONMENT_NAME/service/$SERVICE_UUID"
echo -e "${YELLOW}Nota: Você ainda precisará configurar as variáveis de ambiente sensíveis no Dashboard do Coolify e iniciar o deployment.${NC}"
echo -e "${GREEN}===============================================${NC}"
