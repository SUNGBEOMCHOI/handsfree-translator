from django.urls import path, include
from .views import AudioFileView

urlpatterns = [
    path('audio/upload/', AudioFileView, name='get_audio_file'),
]