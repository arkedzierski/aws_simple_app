from django.db import models

# Create your models here.
class Images(models.Model):
    name = models.CharField(max_length=200)
    pub_date = models.DateTimeField(auto_now_add=True)