from django.conf.urls import patterns, include, url
from django.conf.urls.static import static
from django.conf import settings

from django.contrib import admin

admin.autodiscover()

urlpatterns = patterns(
    '',
    # admin sites:
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),

    # app sites:
    url(r'^accounts/', include('django.contrib.auth.urls')),
    url(r'^staff/', include('bigspoon.bg_order.urls')),
    url(r'^api/v1/', include('bigspoon.bg_api.urls')),
)

if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT
    )
