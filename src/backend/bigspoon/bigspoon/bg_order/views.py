from django.views.generic import TemplateView, ListView, FormView,UpdateView
from bg_inventory.models import Dish


class StaffLoginView(FormView):
    pass


class MainView(TemplateView):
    template_name = "bg_order/main.html"


class MenuView(ListView):
    model = Dish
    template_name = "bg_order/menu.html"

    def get_context_data(self, **kwargs):
        context = super(MenuView, self).get_context_data(**kwargs)
        return context


class TableView(TemplateView):
    template_name = "bg_order/tables.html"


class UserView(TemplateView):
    template_name = "bg_order/user.html"


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
