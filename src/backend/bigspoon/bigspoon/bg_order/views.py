from django.contrib import messages
from django.views.generic import ListView
from django.views.generic.edit import CreateView, UpdateView
from django.core.exceptions import PermissionDenied
from django.db.models import Q

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
        if (outlets.count() == 0):
            raise PermissionDenied
        return super(MainView, self).get_queryset()\
            .prefetch_related('diner', 'orders', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(Q(status=0) | Q(status=2))


class HistoryView(ListView):
    template_name = "bg_order/history.html"
    model = Meal

    def get_queryset(self):
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        if (outlets.count() == 0):
            raise PermissionDenied
        return super(HistoryView, self).get_queryset()\
            .prefetch_related('diner', 'orders', 'table')\
            .filter(table__outlet__in=outlets, status=1)


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
        if (outlets.count() == 0):
            raise PermissionDenied
        return super(MenuView, self).get_queryset()\
            .prefetch_related('outlet', 'categories')\
            .filter(outlet__in=outlets)

    def formset_valid(self, formset):
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
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        if (outlets.count() == 0):
            raise PermissionDenied
        req = super(MenuAddView, self).get(request, *args, **kwargs)
        req.context_data['form']['outlet'].field.initial = outlets[0]
        return req


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


class ReportView(ListView):
    model = Meal
    template_name = "bg_order/report.html"

    # def get_queryset(self):
    #     outlets = get_objects_for_user(
    #         self.request.user,
    #         "change_outlet",
    #         Outlet.objects.all()
    #     )
    #     return super(ReportView, self).get_queryset()\
    #         .prefetch_related('diner', 'orders', 'table')\
    #         .filter(table__outlet__in=outlets)

    def get(self, request, *args, **kwargs):
        temp = super(ReportView, self).get(request, *args, **kwargs)
            # /
            # .prefetch_related('diner', 'orders', 'table')\
            # .filter(table__outlet__in=outlets)
        # temp.context_data['form']['outlet'].field.initial = outlet
        # import ipdb; ipdb.set_trace();
        return temp

    # def get_queryset(self):
    #     #filter queryset based on user's permitted outlet
    #     outlets = get_objects_for_user(
    #         self.request.user,
    #         "change_outlet",
    #         Outlet.objects.all()
    #     )
    #     return super(ReportView, self).get_queryset()\
    #         .filter(outlet__in=outlets)\
    #         .prefetch_related('meals', 'meals__orders')
