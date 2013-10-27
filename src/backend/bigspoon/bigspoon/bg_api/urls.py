from django.conf.urls import patterns, include, url
from rest_framework.urlpatterns import format_suffix_patterns

from bg_api import views

urlpatterns = patterns(
    '',
    # user
    url(r'^user$', views.CreateUser.as_view()),
    url(r'^login$', views.LoginUser.as_view()),
    # ordering
    url(r'^meal$', views.CreateMeal.as_view()),
    url(r'^meal/(?P<pk>[0-9]+)$', views.MealDetail.as_view()),
    url(r'^request$', views.CreateRequest.as_view()),
    # profile
    url(r'^profile$', views.UserProfile.as_view()),
    # outlet
    url(r'^outlets$', views.ListOutlet.as_view()),
    url(r'^outlets/(?P<pk>[0-9]+)$', views.OutletDetail.as_view()),
    # category
    url(r'^categories$', views.ListCategory.as_view()),
    # session auth
    url(r'^web-auth/',
        include('rest_framework.urls', namespace='rest_framework')),
    # documentation
    url(r'^doc/', include('rest_framework_docs.urls')),
)

urlpatterns = format_suffix_patterns(urlpatterns)
