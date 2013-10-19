from django.views.generic import TemplateView, FormView
from django.views.generic.edit import CreateView

from bg_inventory.models import Dish
from bg_inventory.forms import DishCreateForm

from extra_views import ModelFormSetView


class StaffLoginView(FormView):
    pass


class MainView(TemplateView):
    template_name = "bg_order/main.html"


class MenuView(ModelFormSetView):
    template_name = "bg_order/menu.html"
    model = Dish
    fields = ['name', 'desc', 'price', 'pos', 'quantity', 'photo']
    extra = 0

    def get_queryset(self):  # need to only get menu of outlet
        # check current user, check permission
        #
        return super(MenuView, self).get_queryset()

    def formset_valid(self, formset):
        return super(MenuView, self).formset_valid(formset)

    def get_context_data(self, **kwargs):
        #context contains formset, object
        temp = super(MenuView, self).get_context_data(**kwargs)
        # import ipdb;ipdb.set_trace()
        return temp

    def get(self, request, *args, **kwargs):
        temp = super(MenuView, self).get(request, *args, **kwargs)
        # import ipdb;ipdb.set_trace();
        return temp


class MenuAddView(CreateView):
    form_class = DishCreateForm
    template_name = "bg_inventory/dish_form.html"
    success_url = "/staff/menu/"

    #get outlet based on staff logged in
    def form_invalid(self, form):
        return self


class TableView(TemplateView):
    template_name = "bg_order/tables.html"


class UserView(TemplateView):
    template_name = "bg_order/user.html"


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
