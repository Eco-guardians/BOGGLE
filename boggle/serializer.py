from rest_framework import serializers
from boggle.models import Task, Userlist, Quiz, Report, Dictionary


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
