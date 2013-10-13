from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('bigspoon.bg_order.views',
    url(r'^main/$', 'main'),
    url(r'^menu/$', 'menu'),
    url(r'^tables/$', 'tables'),
    url(r'^user/$', 'user'),
    url(r'^history/$', 'history'),
    url(r'^report/$', 'report'),
)