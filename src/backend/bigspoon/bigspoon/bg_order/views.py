from django.contrib import messages
from django.views.generic import TemplateView, ListView
from django.views.generic.edit import CreateView, UpdateView

from extra_views import ModelFormSetView
from guardian.shortcuts import get_objects_for_user

from bg_inventory.models import User, Dish, Outlet, Table
from bg_order.models import Meal

from bg_inventory.forms import DishCreateForm


class MainView(ListView):
    template_name = "bg_order/main.html"
    model = Meal

    def get_queryset(self):
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        return super(MainView, self).get_queryset()\
            .prefetch_related('diner', 'orders', 'table')\
            .filter(table__outlet__in=outlets)


class MenuView(ModelFormSetView):
    template_name = "bg_inventory/menu.html"
    model = Dish
    fields = ['name', 'desc', 'price', 'pos', 'quantity', 'photo',
              'start_time', 'end_time', 'categories']
    extra = 0

    def get_queryset(self):
        #filter queryset based on user's permitted outlet
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        return super(MenuView, self).get_queryset()\
            .prefetch_related('outlet', 'categories')\
            .filter(outlet__in=outlets)

    def formset_valid(self, formset):
        print("Menu update form Valid")
        messages.success(self.request, 'Dish details updated.')
        return super(MenuView, self).formset_valid(formset)


class MenuAddView(CreateView):
    form_class = DishCreateForm
    template_name = "bg_inventory/dish_form.html"
    success_url = "/staff/menu/"

    # def post(self, request, *args, **kwargs):
    #     outlet = get_objects_for_user(self.request.user, "change_outlet",
    #                                   Outlet.objects.all())[0]
    #     temp = super(MenuAddView, self).post(request, *args, **kwargs)
    #     temp.context_data['form']['outlet'].field.initial = outlet
    #     return temp

    def get(self, request, *args, **kwargs):
        outlet = get_objects_for_user(self.request.user, "change_outlet",
                                      Outlet.objects.all())[0]
        temp = super(MenuAddView, self).get(request, *args, **kwargs)
        temp.context_data['form']['outlet'].field.initial = outlet
        return temp


class TableView(ListView):
    model = Table
    template_name = "bg_order/tables.html"

    def get_queryset(self):
        #filter queryset based on user's permitted outlet
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        return super(TableView, self).get_queryset()\
            .filter(outlet__in=outlets)\
            .prefetch_related('meals', 'meals__orders')


class UserView(UpdateView):
    model = User
    template_name = "bg_order/user.html"

    def get(self, request, *args, **kwargs):
        temp = super(UserView, self).get(request, *args, **kwargs)
        return temp


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
