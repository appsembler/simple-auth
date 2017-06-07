from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse


def auth_check(request):
    if not request.user.is_authenticated():
        return HttpResponse('Unauthorized', status=401)
    return HttpResponse("Authenticated as: {0}".format(request.user.email))

