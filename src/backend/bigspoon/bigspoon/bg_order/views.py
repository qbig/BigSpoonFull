from django.contrib import messages
from django.views.generic import TemplateView
from django.views.generic.edit import CreateView

from extra_views import ModelFormSetView

from bg_inventory.models import Dish
from bg_inventory.forms import DishCreateForm


class MainView(TemplateView):
    template_name = "bg_order/main.html"


class MenuView(ModelFormSetView):
    template_name = "bg_order/menu.html"
    model = Dish
    fields = ['name', 'desc', 'price', 'pos', 'quantity', 'photo']
    extra = 0

    def get_queryset(self):
        # check current user, check permission and filter queryset!
        return super(MenuView, self).get_queryset()

    def formset_valid(self, formset):
        # import ipdb;ipdb.set_trace();
        print("Menu update form Valid")
        messages.success(self.request, 'Dish details updated.')
        return super(MenuView, self).formset_valid(formset)

    def formset_invalid(self, formset):
        print("Menu update form invalid")
        return super(MenuView, self).formset_invalid(formset)

    def get_context_data(self, **kwargs):
        temp = super(MenuView, self).get_context_data(**kwargs)
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
    def formset_valid(self, formset):
        print("Form Valid")
        return super(MenuAddView, self).formset_valid(formset)

    def formset_invalid(self, formset):
        print("Form invalid")
        return super(MenuAddView, self).formset_invalid(formset)


class TableView(TemplateView):
    template_name = "bg_order/tables.html"


class UserView(TemplateView):
    template_name = "bg_order/user.html"


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
