from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
# Create your views here.
from rds.models import Images
from django.views.generic.edit import CreateView
from django.urls import reverse_lazy


def index(request):
    latest_images = Images.objects.order_by('-pub_date')[:5]
    template = loader.get_template('rds/index.html')
    context = {
        'latest_images': latest_images,
    }
    return HttpResponse(template.render(context, request))

class DocumentCreateView(CreateView):
    model = Images
    fields = ['name', ]
    success_url = reverse_lazy('index')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        return context