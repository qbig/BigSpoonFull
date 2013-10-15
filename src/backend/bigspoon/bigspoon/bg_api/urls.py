from django.conf.urls import patterns, include, url
from django.conf import settings

from rest_framework import routers

from bg_api import views

router = routers.DefaultRouter()
router.register(r'dishes', views.DishViewSet)

urlpatterns = patterns(
    '',
    url(r'^v1/', include(router.urls)),
)

if settings.DEBUG:
    urlpatterns += patterns(
        '',
        url(r'^auth/',
            include('rest_framework.urls', namespace='rest_framework')),
    )
