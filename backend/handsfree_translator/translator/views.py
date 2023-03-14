from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import AudioModel
from .serializers import AudioFileSerializer
import random

@api_view(['GET'])
def AudioFileView(request):
    audio_file_name = request.GET.get('audio_file_name')
    audio_file = request.GET.get('audio_file')
    request_type = request.GET.get('request_type')

    serializer = AudioFileSerializer(data={
        'audio_file_name':audio_file_name,
        'audio_file':audio_file,
        'request_type': request_type,
    })
    serializer.is_valid()
    return Response(serializer.data)