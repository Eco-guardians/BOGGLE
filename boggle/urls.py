from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from boggle import views
from django.urls import path



app_name = 'boggle'

urlpatterns = [
    path('', views.getTaskList, name='getTaskList'),  
    path('addTask', views.addTask, name='addTask'),
    path('updateTask/<int:pk>/<str:work>', views.updateTask, name='updateTask'),
    path("deleteTask/<int:pk>", views.deleteTask, name='deleteTask'),
    path('user_info/<int:user_id>/', views.get_user_info, name='get_user_info'),

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

    path('update_user_points/', views.update_user_points, name='user_points'),
    path('user_points/<str:user_id>/', views.get_user_points, name='user_points'),

]


