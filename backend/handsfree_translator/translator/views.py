from rest_framework.response import Response
from rest_framework.decorators import api_view, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser
from .models import AudioModel
from .serializers import AudioFileSerializer
from translator.apps import TranslatorConfig


@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser])
def AudioFileView(request):
    audio_file_name = request.data.get('audio_file_name')
    audio_file = request.data.get('audio_file')
    request_type = request.data.get('request_type')
    serializer = AudioFileSerializer(data={
        'audio_file_name':audio_file_name,
        'audio_file':audio_file,
        'request_type': request_type,
    })
    if serializer.is_valid():
        serializer.save()
        return TranslatorConfig.translator.translate(serializer.data)
    else:
        return Response(serializer.errors, status=400)