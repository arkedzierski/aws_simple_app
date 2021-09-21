from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
# Create your views here.
from rds.models import Images

def index(request):
    latest_images = Images.objects.order_by('-pub_date')[:5]
    template = loader.get_template('rds/index.html')
    context = {
        'latest_images': latest_images,
    }
    return HttpResponse(template.render(context, request))