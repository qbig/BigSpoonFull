from django.conf.urls import patterns, url
from bg_order.views import MainView, MenuView, TableView, UserView, \
    HistoryView, ReportView

urlpatterns = patterns(
    '',
    url(r'^main/$', MainView.as_view(), name='staff_main'),
    url(r'^menu/$', MenuView.as_view(), name='staff_menu'),
    url(r'^tables/$', TableView.as_view(), name='staff_table'),
    url(r'^user/$', UserView.as_view(), name='staff_user'),
    url(r'^history/$', HistoryView.as_view(), name='staff_history'),
    url(r'^report/$', ReportView.as_view(), name='staff_report'),
)
