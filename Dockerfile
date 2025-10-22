# ----------------------------------------------------------------------
# ESTÁGIO 0: FRONTEND BUILDER (Build React app)
# ----------------------------------------------------------------------
FROM node:18-alpine as frontend-builder

WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

# ----------------------------------------------------------------------
# ESTÁGIO 1: BUILDER (Instala dependências do OS e Python)
# Objetivo: Criar o Venv e coletar estáticos como root (com ferramentas)
# ----------------------------------------------------------------------
FROM python:3.12-slim-bookworm as builder

# Define o diretório de trabalho DENTRO DO CONTAINER
WORKDIR /app

# 1. Instalação do uv: Copia os binários pré-compilados (uv e uvx).
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/
COPY --from=ghcr.io/astral-sh/uv:latest /uvx /usr/local/bin/

# Instalação das dependências do OS para compilação (dentro do container)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        zlib1g-dev libjpeg-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copia apenas os arquivos de dependência
COPY pyproject.toml uv.lock ./

# Cria e popula o virtual environment (venv)
# O cache do uv fica isolado (via mount) e a instalação é rápida.
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync

# Copia o código da aplicação
COPY . .

# Comando para coletar arquivos estáticos (dentro do container)
# Usa 'uv run' para garantir que o python do venv seja encontrado.
RUN uv run python manage.py collectstatic --noinput

# ----------------------------------------------------------------------
# ESTÁGIO 2: PRODUCTION (Imagem de runtime - Mínima e segura)
# Objetivo: Copiar artefatos, criar um usuário seguro e iniciar a aplicação.
# ----------------------------------------------------------------------
FROM python:3.12-slim-bookworm as production

# Define o diretório de trabalho DENTRO DO CONTAINER
WORKDIR /app

# 1. Instala dependências de OS APENAS de RUNTIME
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpq5 \
        zlib1g libjpeg62-turbo \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 2. Copia o binário do uv do builder para usar uv run
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv
COPY --from=builder /usr/local/bin/uvx /usr/local/bin/uvx

# 3. Copia o venv e o código da app do estágio 'builder' (ainda como root)
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app /app

# 3.1. Copia o frontend build do estágio frontend-builder
COPY --from=frontend-builder /frontend/build /app/frontend/build

# 4. CRIAÇÃO E CONFIGURAÇÃO DE USUÁRIO (CORRIGIDO)
#    --create-home: Permite que o usuário tenha um local de trabalho, resolvendo o erro 13.
RUN useradd --create-home --uid 1000 appuser

#    Transfere a propriedade de /app e todos os seus conteúdos (incluindo o venv)
#    para o appuser, dando a ele as permissões necessárias.
RUN chown -R appuser:appuser /app

# 5. Define o Usuário não-root
USER appuser

# 6. Configura o PATH (dentro do container)
ENV PATH="/app/.venv/bin:$PATH"

# Define a porta
EXPOSE 8000

# 7. Define o comando de inicialização
# Note que 'config.wsgi:application' precisa ser o caminho correto do seu WSGI
CMD uv run gunicorn config.wsgi:application --bind 0.0.0.0:8000
