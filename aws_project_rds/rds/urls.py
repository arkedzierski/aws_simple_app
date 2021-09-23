from django.urls import path

from rds.views import index, DocumentCreateView



urlpatterns = [
    path('', index, name='index'),
    path('s3/', DocumentCreateView.as_view(), name='s3'),
]