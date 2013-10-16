from django.conf.urls import patterns, include, url
from rest_framework.urlpatterns import format_suffix_patterns

from bg_api import views

urlpatterns = patterns(
    '',
    # user
    url(r'^user$', views.CreateUser.as_view()),
    # outlet
    url(r'^outlets$', views.ListOutlet.as_view()),
    url(r'^outlets/(?P<pk>[0-9]+)$', views.OutletDetail.as_view()),
    url(r'^web-auth/',
        include('rest_framework.urls', namespace='rest_framework')),
    url(r'^token-auth/',
        'rest_framework.authtoken.views.obtain_auth_token'),
)

urlpatterns = format_suffix_patterns(urlpatterns)
