from django.urls import path

from rds.views import index

urlpatterns = [
    path('', index, name='index'),
]