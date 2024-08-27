from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from boggle import views
from django.urls import path
import rest_framework
from . import views
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CertificationViewSet



app_name = 'boggle'

router = DefaultRouter()
router.register(r'certifications', CertificationViewSet)


urlpatterns = [
    path('', views.getTaskList, name='getTaskList'),  
    path('addTask', views.addTask, name='addTask'),
    path('updateTask/<int:pk>/<str:work>', views.updateTask, name='updateTask'),
    path("deleteTask/<int:pk>", views.deleteTask, name='deleteTask'),
    path('user_info/<str:user_id>/', views.get_user_info, name='get_user_info'),

    path('quiz_data_api', views.quiz_data_api, name='quiz_data_api'),
    path('check_answer/', views.check_answer, name='check_answer'),


    path('addReport', views.addReport, name='addReport'),
    path('getReportList', views.getReportList, name='getReportList'),
    path('updateReport/<int:pk>/', views.updateReport, name='updateReport'),
    path('deleteReport/<int:pk>/', views.deleteReport, name='deleteReport'),

    path('register/', views.register_user, name='register_user'), 
    path('find_user_id/', views.find_user_id, name='find_user_id'),
    path('find_user_password/', views.find_user_password, name='find_user_password'),
    path('update_password/', views.update_password, name='update_password'),

    path('update_user_points/', views.update_user_points, name='update_user_points'),
    path('update_user_item/<str:user_id>/<int:point>', views.update_user_item, name='update_user_item'),
    path('buy_user_item/<str:user_id>/<int:point>', views.buy_user_item, name='buy_user_item'),
    path('sub_user_points/', views.sub_user_points, name='sub_user_points'),
    path('user_points/<str:user_id>/', views.get_user_points, name='user_points'),

    path('login_view/', views.login_view, name='login_view'),
    path('get_water_quality/', views.get_water_quality, name='get_water_quality'),
    path('update_user_info/', views.update_user_info, name='update_user_info'),
    path('change_password/', views.change_password, name='change_password'),
    path('withdraw/<str:user_id>/', views.withdraw, name='withdraw'),
    path('detect/', views.detect_view, name='detect'),
    path('api/', include(router.urls)),

    path('create_post/', views.create_community_post, name='create_post'),
    path('recruitment_posts/', views.get_recruitment_posts, name='recruitment_posts'),
]
