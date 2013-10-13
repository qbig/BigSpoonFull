from django.conf.urls import patterns, include, url

from django.contrib import admin

admin.autodiscover()

urlpatterns = patterns(
    '',
    # admin sites:
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^main/$', 'bg_order.views.main'),
    url(r'^menu/$', 'bg_order.views.menu'),
    url(r'^tables/$', 'bg_order.views.tables'),
    url(r'^user/$', 'bg_order.views.user'),
)
