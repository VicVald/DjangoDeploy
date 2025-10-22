"""
Configuração do Celery para o projeto Django.
"""
import os
from celery import Celery

# Define o módulo de configurações padrão do Django para o programa 'celery'.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

# Cria a instância do Celery
app = Celery('config')

# Carrega as configurações do Django usando o namespace 'CELERY'
# Isso significa que todas as configurações do Celery no settings.py
# devem começar com 'CELERY_'
app.config_from_object('django.conf:settings', namespace='CELERY')

# Carrega automaticamente tasks.py de todos os apps registrados
app.autodiscover_tasks()


@app.task(bind=True, ignore_result=True)
def debug_task(self):
    """Task de exemplo para debugging"""
    print(f'Request: {self.request!r}')
