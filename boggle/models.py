from django.db import models

class Task(models.Model):
    id = models.AutoField(primary_key=True)
    work = models.CharField(max_length=400, default='null')
    isComplete = models.BooleanField(default=False)
    image = models.ImageField(upload_to='task_images/', null=True, blank=True)
# Create your models here.
# models.py

from django.db import models

class Quiz(models.Model):
    question = models.CharField(max_length=255)
    correct_answer = models.CharField(max_length=100)
    wrong_answers = models.JSONField()

# dust_checker/models.py

class Dictionary(models.Model):
    hNm = models.CharField(max_length=255, blank=True, null=True)
    explain = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.hNm if self.hNm else "Unnamed"


class Report(models.Model):
    id = models.AutoField(primary_key=True)
    work = models.CharField(max_length=400, default='null')
    title = models.CharField(max_length=400, default='null')
    image = models.ImageField(upload_to='task_images_2/', null=True, blank=True)

class Userlist(models.Model):
    id = models.CharField(primary_key=True, unique=True, max_length=50)
    nickname = models.CharField(null=False, max_length=30)  
    password = models.CharField(null=False, max_length=128) 
    location = models.CharField(null=False, max_length=100) 
    email = models.EmailField(null=False, unique=True, max_length=254)  
