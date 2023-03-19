from django.apps import AppConfig

from .api import Translator

class TranslatorConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'translator'
    translator = Translator()