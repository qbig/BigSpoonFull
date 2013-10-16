from django.views.generic import TemplateView, FormView
from bg_inventory.models import Dish

from extra_views import ModelFormSetView


class StaffLoginView(FormView):
    pass


class MainView(TemplateView):
    template_name = "bg_order/main.html"


class MenuView(ModelFormSetView):
    model = Dish
    # form_class = MenuDishForm
    template_name = "bg_order/menu.html"

    def get_context_data(self, **kwargs):
        context = super(MenuView, self).get_context_data(**kwargs)
        return context

    # By default this will populate the formset with all the instances of MyModel in the database. You can control this by overriding get_queryset
    # def get_queryset(self):
    #     slug = self.kwargs['slug']
    #     return super(MyModelFormSetView, self).get_queryset().filter(slug=slug)


class TableView(TemplateView):
    template_name = "bg_order/tables.html"


class UserView(TemplateView):
    template_name = "bg_order/user.html"


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
