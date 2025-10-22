# Django Deploy

Aplicação Django completa com Docker, PostgreSQL, RabbitMQ e Celery.

## 🚀 Deploy no Docker Hub

### Pré-requisitos

1. **Conta no Docker Hub**: [docker.com](https://hub.docker.com)
2. **Docker instalado** em sua máquina
3. **Conta logada**: `docker login`

### 📦 Build e Push da Imagem

#### Opção 1: Usando o script automático

```bash
# Build da imagem
./build-and-push.sh

# Ou com tag específica
./build-and-push.sh v1.0.0
```

#### Opção 2: Comandos manuais

```bash
# 1. Build da imagem
docker build -t djangodeploy:latest .

# 2. Login no Docker Hub
docker login

# 3. Tag da imagem (substitua SEU_USERNAME)
docker tag djangodeploy:latest SEU_USERNAME/djangodeploy:latest

# 4. Push para Docker Hub
docker push SEU_USERNAME/djangodeploy:latest
```

### 🏃‍♂️ Como usar a imagem

#### Com Docker Compose (Recomendado)

```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    image: SEU_USERNAME/djangodeploy:latest
    ports:
      - "8000:8000"
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings
      - SECRET_KEY=sua-secret-key-aqui
      - DEBUG=False
      - DB_HOST=db
      - DB_NAME=myproject
      - DB_USER=myprojectuser
      - DB_PASSWORD=password
    depends_on:
      - db
      - broker

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=myproject
      - POSTGRES_USER=myprojectuser
      - POSTGRES_PASSWORD=password

  broker:
    image: rabbitmq:3.13-management-alpine
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin
```

#### Apenas com Docker

```bash
# Rodar apenas a aplicação (sem banco)
docker run -p 8000:8000 \
  -e SECRET_KEY=sua-secret-key \
  -e DEBUG=False \
  SEU_USERNAME/djangodeploy:latest
```

### 🔧 Configurações de Ambiente

| Variável | Descrição | Padrão |
|----------|-----------|---------|
| `SECRET_KEY` | Chave secreta do Django | (obrigatório) |
| `DEBUG` | Modo debug | `False` |
| `ALLOWED_HOSTS` | Hosts permitidos | `*` |
| `DB_HOST` | Host do banco | `localhost` |
| `DB_NAME` | Nome do banco | `myproject` |
| `DB_USER` | Usuário do banco | `myprojectuser` |
| `DB_PASSWORD` | Senha do banco | `password` |
| `CELERY_BROKER_URL` | URL do broker Celery | `amqp://guest:guest@localhost:5672//` |

### 📋 Funcionalidades

- ✅ **Django 5.2** com Gunicorn
- ✅ **PostgreSQL** como banco de dados
- ✅ **RabbitMQ** como message broker
- ✅ **Celery** para tarefas assíncronas
- ✅ **Nginx** como proxy reverso
- ✅ **Arquivos estáticos** servidos pelo Nginx
- ✅ **Multi-stage build** otimizado
- ✅ **UV** para gerenciamento de dependências

### 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐
│   Nginx (80)    │────│  Gunicorn (8000)│
│                 │    │                 │
│ - Static Files  │    │ - Django App    │
│ - Proxy Reverse │    └─────────────────┘
└─────────────────┘             │
                                │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   (5432)        │
                    └─────────────────┘
                                │
                    ┌─────────────────┐
                    │   RabbitMQ      │
                    │   (5672/15672)  │
                    └─────────────────┘
                                │
                    ┌─────────────────┐
                    │   Celery Worker │
                    │                 │
                    └─────────────────┘
```

### 🔒 Segurança

- Usuário não-root no container
- Imagem slim do Python
- Apenas dependências de runtime
- Cache do UV isolado

### 📊 Otimizações

- **Multi-stage build**: Imagem final menor
- **UV**: Instalação rápida de dependências
- **.dockerignore**: Build mais eficiente
- **Cache layers**: Builds incrementais

---

**📝 Nota**: Substitua `SEU_USERNAME` pelo seu nome de usuário do Docker Hub.