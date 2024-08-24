from django.contrib import admin
from .models import Quiz, Report, Userlist
from boggle.models import Task
from .models import Dictionary
from .models import CommunityPost

admin.site.register(Task)
admin.site.register(Quiz)
admin.site.register(Dictionary)
admin.site.register(Report)
admin.site.register(Userlist)
admin.site.register(CommunityPost)
# Register your models here.
