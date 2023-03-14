from rest_framework import serializers
from .models import AudioModel

class AudioFileSerializer(serializers.ModelSerializer):
    class Meta:
        model = AudioModel
        fields = ('audio_file_name', 'audio_file', 'request_type')