from django.conf import settings
from django.shortcuts import render_to_response, redirect
from django.contrib import messages

from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from allauth.account.adapter import DefaultAccountAdapter
from allauth.exceptions import ImmediateHttpResponse


class NoSignupAccountAdapter(DefaultAccountAdapter):
    def is_open_for_signup(self, request):
        return False

class OrganizationSpecificSocialLogin(DefaultSocialAccountAdapter):
    def is_open_for_signup(self, request, sociallogin):
        return True

    def pre_social_login(self, request, sociallogin):
        u = sociallogin.user
        if not u.email.split('@')[1] in settings.ALLOWED_DOMAINS:
            messages.add_message(request, messages.ERROR,
                    'Invalid Organization. Allowed organizations are: {0}'.format(
                        ', '.join(settings.ALLOWED_DOMAINS)))
            raise ImmediateHttpResponse(redirect('account_login'))

