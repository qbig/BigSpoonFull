from django.conf.urls.defaults import patterns
from bg_order.views import MainView, MenuView, TableView, UserView, \
    HistoryView, ReportView

urlpatterns = patterns('',
    (r'^main/$', MainView.as_view()),
    (r'^menu/$', MenuView.as_view()),
    (r'^tables/$', TableView.as_view()),
    (r'^user/$', UserView.as_view()),
    (r'^history/$', HistoryView.as_view()),
    (r'^report/$', ReportView.as_view()),
)