from django.urls import path, include
from .views import audio

urlpatterns = [
    path('get-audio-file/', audio.as_view(), name='get_audio_file'),
]