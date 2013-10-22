from django.contrib import messages
from django.views.generic import TemplateView
from django.views.generic.edit import CreateView

from extra_views import ModelFormSetView
from guardian.shortcuts import get_objects_for_user

from bg_inventory.models import Dish, Outlet
from bg_inventory.forms import DishCreateForm


class MainView(TemplateView):
    template_name = "bg_order/main.html"


class MenuView(ModelFormSetView):
    template_name = "bg_order/menu.html"
    model = Dish
    fields = ['name', 'desc', 'price', 'pos', 'quantity', 'photo',
              'start_time', 'end_time']
    extra = 0

    def get_queryset(self):
        #filter queryset based on user's permitted outlet
        outlet = get_objects_for_user(self.request.user, "change_outlet",
                                      Outlet.objects.all())[0]
        return super(MenuView, self).get_queryset().filter(outlet=outlet)

    def formset_valid(self, formset):
        print("Menu update form Valid")
        messages.success(self.request, 'Dish details updated.')
        return super(MenuView, self).formset_valid(formset)

    def formset_invalid(self, formset):
        print("Menu update form invalid")
        return super(MenuView, self).formset_invalid(formset)

    def get_context_data(self, **kwargs):
        # import ipdb;ipdb.set_trace();
        temp = super(MenuView, self).get_context_data(**kwargs)
        return temp

    def get(self, request, *args, **kwargs):
        temp = super(MenuView, self).get(request, *args, **kwargs)
        return temp


class MenuAddView(CreateView):
    form_class = DishCreateForm
    template_name = "bg_inventory/dish_form.html"
    success_url = "/staff/menu/"

    def formset_valid(self, formset):
        print("Menu add Form Valid")
        return super(MenuAddView, self).formset_valid(formset)

    def formset_invalid(self, formset):
        print("Menu add Form invalid")
        return super(MenuAddView, self).formset_invalid(formset)

    def get(self, request, *args, **kwargs):
        outlet = get_objects_for_user(self.request.user, "change_outlet",
                                      Outlet.objects.all())[0]
        temp = super(MenuAddView, self).get(request, *args, **kwargs)
        temp.context_data['form']['outlet'].field.initial = outlet
        return temp


class TableView(TemplateView):
    template_name = "bg_order/tables.html"


class UserView(TemplateView):
    template_name = "bg_order/user.html"


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
