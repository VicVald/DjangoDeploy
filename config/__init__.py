"""
Inicialização do pacote config.
Garante que o Celery é carregado quando o Django inicia.
"""

# Isso garante que o app Celery será sempre importado quando o Django iniciar
# para que as tasks compartilhadas usem este app
from .celery import app as celery_app

__all__ = ('celery_app',)
