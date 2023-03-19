import os
import urllib
import json
import time
from django.http import FileResponse
import openai
from google.cloud import texttospeech

# Get API Keys
api_path = '../../api key/'


class OpenAI:
    def __init__(self):
        openai_api_path = os.path.join(api_path, 'openai.txt')

        with open(openai_api_path, 'r') as f:
            OPENAI_API_KEY, OPENAI_ORGANIZATION = f.readline().rstrip('\n').split(' ')

        openai.organization = OPENAI_ORGANIZATION
        openai.api_key = OPENAI_API_KEY
         
    def transcribe(self, audio_path, language):
        """
        Speech recognition audio file of 'source language' to text of 'source language'

        Args:
            audio_path: Path to audio file
            language: Language of audio data

        Returns:
            Transcribed text of 'source language'
        """
        with open(audio_path, "rb") as audio_file:
            text_transcript = openai.Audio.transcribe("whisper-1", audio_file, language=language)
            return text_transcript.text
        
    def translate(self, audio_path):
        """
        Translate source language audio file to english

        Args:
            audio_path: Path to audio file

        Returns:
            Translated english text
        """
        with open(audio_path, "rb") as audio_file:
            text_transcript = openai.Audio.translate("whisper-1", audio_file)
            return text_transcript.text
        
class Papago:
    def __init__(self):
        naver_api_path = os.path.join(api_path, 'naver.txt')

        with open(naver_api_path, 'r') as f:
            self.NAVER_API_KEY_ID, self.NAVER_API_KEY_ID_SECRET = f.readline().rstrip('\n').split(' ')

    def translate(self, text, src_language='en', trg_language='ko'):
        """
        Translate text of 'source language' to text of 'target language'

        Args:
            text: Text you want to translate
            src_language: Language of input text
            trg_language: Language you want to be translated into
        """
        encText = urllib.parse.quote(text)
        data = f"source={src_language}&target={trg_language}&text={encText}"
        url = "https://openapi.naver.com/v1/papago/n2mt"
        request = urllib.request.Request(url)
        request.add_header("X-Naver-Client-Id", self.NAVER_API_KEY_ID)
        request.add_header("X-Naver-Client-Secret", self.NAVER_API_KEY_ID_SECRET)
        response = urllib.request.urlopen(request, data=data.encode("utf-8"))
        rescode = response.getcode()
        if(rescode==200):
            response_body = response.read()
            json_output = json.loads(response_body.decode('utf-8'))
            translate_result = json_output['message']['result']['translatedText']
            return translate_result
        else:
            print("Papago Error Code:" + rescode)
            
class Google:
    def __init__(self):
        google_api_path = os.path.join(api_path, 'google.txt')

        with open(google_api_path, 'r') as f:
            GOOGLE_API_KEY = f.readline().rstrip('\n')

        self.client = texttospeech.TextToSpeechClient()

    def tts(self, text, language, output_file_path):
        """
        Text to speech with google API

        Args:
            text: Text to be converted to speech
            language: Language of input text
            output_file_path: Path to output speech file
        """
        synthesis_input = texttospeech.SynthesisInput(text=text)
        if language == 'ko':
            voice_type = 'ko-KR-Standard-B'
            voice_gender = 'FEMALE'
            voice = texttospeech.VoiceSelectionParams(
                language_code="ko-KR", name=voice_type, ssml_gender=voice_gender
            )
        elif language == 'en':
            voice_type = 'en-US-Standard-C'
            voice_gender = 'FEMALE'
            voice = texttospeech.VoiceSelectionParams(
                language_code="en-US", name=voice_type, ssml_gender=voice_gender
            )
        else:
            raise NotImplementedError
        audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3
        )
        response = self.client.synthesize_speech(
            input=synthesis_input, voice=voice, audio_config=audio_config
        )
        with open(output_file_path, "wb") as out:
            # Write the response to the output file.
            out.write(response.audio_content)
        return output_file_path

class Translator:
    def __init__(self):
        self.openai = OpenAI()
        self.papago = Papago()
        self.google = Google()
        self.audio_dir_path = './media/audio_files'

    def translate(self, data):
        """
        Translate input source language audio files into target language audio files and text
        
        Args:
            data: HTTP request which contains 'audio file name', 'audio file', 'request type'
            request type is one of [ko2en, en2ko]

        Returns:
            HTTP response which contains 'translated audio file name', 'translated audio file', 'translated text', 'request type'
        """
        audio_file_name = data['audio_file_name']
        audio_file = data['audio_file']
        request_type = data['request_type']
        audio_path = os.path.join(self.audio_dir_path, audio_file_name)
        old_base_name, file_ext = os.path.splitext(audio_file_name)

        # Create the new file path with the new basename
        new_base_name = old_base_name + f'_{request_type}' + file_ext
        output_audio_path = os.path.join(self.audio_dir_path, new_base_name)

        src_language, trg_language = request_type.split('2')
        if request_type == 'ko2en':
            ko_audio_path = audio_path
            en_text = self.openai.translate(ko_audio_path)
            output_text = en_text
            output_audio_path = self.google.tts(output_text, trg_language, output_audio_path)
        elif request_type == 'en2ko':
            en_audio_path = audio_path
            en_text = self.openai.transcribe(en_audio_path, src_language)
            ko_text = self.papago.translate(en_text, src_language, trg_language)
            output_text = ko_text
            output_audio_path = self.google.tts(output_text, trg_language, output_audio_path)
        else:
            raise NotImplementedError
        
        content_type = 'audio/mpeg'
        response = FileResponse(open(output_audio_path, 'rb'), content_type=content_type)
        response['audio_file_name'] = new_base_name
        response['translated_text'] = output_text
        response['request_type'] = request_type
        return response
        