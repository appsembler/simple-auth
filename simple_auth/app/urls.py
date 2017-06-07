from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^check/$', views.auth_check, name='app_auth_check'),
]

