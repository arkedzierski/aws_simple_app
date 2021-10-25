from django.urls import path

from rds.views import index, DocumentCreateView
from django.views.generic.base import RedirectView



urlpatterns = [
    path('', RedirectView.as_view(url='/db/')),
    path('db/', index, name='index'),
    path('add/', DocumentCreateView.as_view(), name='s3'),
]
