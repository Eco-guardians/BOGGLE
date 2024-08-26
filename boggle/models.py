from django.db import models
from django.utils import timezone

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
# models.py

from django.db import models

class Report(models.Model):
    id = models.AutoField(primary_key=True)
    work = models.CharField(max_length=400, default='null')
    title = models.CharField(max_length=400, default='null')
    image = models.ImageField(upload_to='task_images_2/', null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)  # 위도
    longitude = models.FloatField(null=True, blank=True)  # 경도

  
class Userlist(models.Model):
    id = models.CharField(primary_key=True, unique=True, max_length=50)
    nickname = models.CharField(null=False, max_length=30)  
    password = models.CharField(null=False, max_length=128) 
    location = models.CharField(null=False, max_length=100) 
    email = models.EmailField(null=False, unique=True, max_length=254)  
    point = models.BigIntegerField(default=0)
    rank = models.BigIntegerField(default = 1)


# community/models.py
from django.db import models

class CommunityPost(models.Model):
    POST_TYPE_CHOICES = [
        ('일반 게시글', '일반 게시글'),
        ('참여자 모집', '참여자 모집'),
    ]

    title = models.CharField(max_length=200)
    content = models.TextField(blank=True)
    post_type = models.CharField(max_length=50, choices=POST_TYPE_CHOICES, default='일반 게시글')
    date = models.DateTimeField(auto_now_add=True)
    image = models.ImageField(upload_to='post_images/', blank=True, null=True)
    
    # 추가 필드: 참여자 모집 관련
    recruitment_people = models.PositiveIntegerField(blank=True, null=True)
    recruitment_date = models.DateField(blank=True, null=True)
    recruitment_deadline = models.DateField(blank=True, null=True)
    recruitment_area = models.CharField(max_length=100, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return self.title
    
from django.contrib.postgres.fields import ArrayField
from django.db import models

class Item(models.Model):
    items = ArrayField(models.CharField(max_length=20), blank=False)



    

