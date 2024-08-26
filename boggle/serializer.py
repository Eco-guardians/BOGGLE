from rest_framework import serializers
import base64
from django.core.files.base import ContentFile
from boggle.models import Task, Userlist, Quiz, Report, Dictionary
from boggle.models import CommunityPost

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ('id', 'work','isComplete','image')



class QuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = Quiz
        fields = '__all__'


# serializers.py

class ReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields = ['id', 'title', 'work', 'image', 'latitude', 'longitude']

class UserlistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Userlist
        fields = ('id', 'nickname','password','location', 'email', 'point')

class CommunityPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommunityPost
        fields = '__all__'
        extra_kwargs = {
            'content': {'required': True},
            'user_name': {'required': True}, 
        }