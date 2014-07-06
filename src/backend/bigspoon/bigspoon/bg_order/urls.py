from django.conf.urls import patterns, url
from django.contrib.auth.decorators import login_required
from bg_order.views import MainView, MenuView, TableView, UserView,\
    HistoryView, ReportView, MenuAddView, DishPhotoUpdateView

urlpatterns = patterns('',
    url(r'^main/$', login_required(MainView.as_view()), name='staff_main'),
    url(r'^menu/$', login_required(MenuView.as_view()), name='staff_menu'),
    url(r'^menu/dish/(?P<pk>[0-9]+)$', login_required(DishPhotoUpdateView.as_view()), name='dish_pic_update'),
    url(r'^menu/add/$', login_required(MenuAddView.as_view()), name='staff_menu_add'),
    url(r'^tables/$', login_required(TableView.as_view()), name='staff_table'),
    url(r'^user/(?P<pk>[0-9]+)$', login_required(UserView.as_view()), name='staff_user'),
    url(r'^history/$', login_required(HistoryView.as_view()), name='staff_history'),
    url(r'^report/$', login_required(ReportView.as_view()), name='staff_report'),
)
