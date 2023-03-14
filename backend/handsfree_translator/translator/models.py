from django.db import models
from audiofield.fields import AudioField

# Create your models here.
class AudioModel(models.Model):
    audio_file_name = models.CharField(max_length=10)
    audio_file = AudioField(upload_to='', blank=True)
    request_type = models.CharField(max_length=10)