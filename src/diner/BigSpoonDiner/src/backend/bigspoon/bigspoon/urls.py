from django.conf.urls import patterns, include, url
from django.conf.urls.static import static
from django.conf import settings

from django.contrib import admin
from bg_order.views import IndexView

admin.autodiscover()

urlpatterns = patterns(
    '',
    # admin sites:
    url(r'^$', IndexView.as_view(), name='index'),
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),

    # app sites:
    url(r'^accounts/login/$', 'django.contrib.auth.views.login',
        name='login'),
    url(r'^accounts/logout/$', 'django.contrib.auth.views.logout',
        {'next_page': '/accounts/login'}, name='logout'),
    url(r'^accounts/', include('django.contrib.auth.urls')),
    url(r'^staff/', include('bigspoon.bg_order.urls')),
    url(r'^api/v1/', include('bigspoon.bg_api.urls')),
    # socketio view
    url(r'^socket\.io', 'bigspoon.bg_inventory.views.socketio'),
)

if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT
    )
