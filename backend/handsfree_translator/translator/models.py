from django.db import models

# Create your models here.
class AudioModel(models.Model):
    audio_file_name = models.CharField(max_length=100, blank=False, null=False)
    audio_file = models.FileField(upload_to='audio_files/', blank=False, null=False)
    request_type = models.CharField(max_length=10, blank=False, null=False)