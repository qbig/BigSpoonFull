from django.conf.urls import patterns, include, url
from rest_framework.urlpatterns import format_suffix_patterns

from bg_api import views

urlpatterns = patterns(
    '',
    # user
    url(r'^user$', views.CreateUser.as_view()),
    url(r'^login$', views.LoginUser.as_view()),
    url(r'^fblogin$', views.FBLogin.as_view()),
    # ordering
    url(r'^mealhistory$', views.MealHistory.as_view()),
    url(r'^meal$', views.CreateMeal.as_view()),
    url(r'^meal-update$', views.UpdateNewOrderForMeal.as_view()),
    url(r'^table$', views.UpdateTableForMeal.as_view()),
    url(r'^table-single-diner$', views.UpdateTableForMealForSingleDiner.as_view()),
    url(r'^order$', views.UpdateOrder.as_view()),
    url(r'^askbill$', views.AskForBill.as_view()),
    url(r'^meal/(?P<pk>[0-9]+)$', views.MealDetail.as_view()),
    url(r'^dish/(?P<pk>[0-9]+)$', views.UpdateDish.as_view()),
    url(r'^request$', views.CreateRequest.as_view()),
    url(r'^spending$', views.GetSpendingData.as_view()),
    url(r'^note$', views.CreateNote.as_view()),
    # rating
    url(r'^rating$', views.CreateRating.as_view()),
    # review
    url(r'^review$', views.CreateReview.as_view()),
    # profile
    url(r'^profile$', views.UserProfile.as_view()),
    # outlet
    url(r'^outlets$', views.ListOutlet.as_view()),
    url(r'^outlets/(?P<pk>[0-9]+)$', views.OutletDetail.as_view()),
    # category
    url(r'^categories$', views.ListCategory.as_view()),
    # search outlet by dish
    url(r'^searchdish$', views.SearchOutletByDish.as_view()),
    # session auth
    url(r'^web-auth/',
        include('rest_framework.urls', namespace='rest_framework')),
    # documentation
    url(r'^doc/', include('rest_framework_docs.urls')),
    # staff app API
    url(r'^closebill$', views.CloseBill.as_view()),
    url(r'^ackorder$', views.AckOrder.as_view()),
    url(r'^ackreq$', views.AckRequest.as_view()),

)

urlpatterns = format_suffix_patterns(urlpatterns)
