from django.contrib import messages
from django.views.generic import ListView, TemplateView
from django.views.generic.edit import CreateView
from django.core.exceptions import PermissionDenied
from django.db.models import Q
from django.contrib.auth import get_user_model
from django.http import Http404

from extra_views import ModelFormSetView
from guardian.shortcuts import get_objects_for_user

from bg_inventory.models import Dish, Outlet, Table, Review, Note
from bg_order.models import Meal, Request

from bg_inventory.forms import DishCreateForm
from utils import send_socketio_message, today_limit

User = get_user_model()


class MainView(TemplateView):
    template_name = "bg_order/main.html"

    def get_context_data(self, **kwargs):
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        if (outlets.count() == 0):
            raise PermissionDenied
        context = super(MainView, self).get_context_data(**kwargs)
        context['meal_cards'] = Meal.objects\
            .prefetch_related('diner', 'orders', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(Q(status=Meal.ACTIVE) | Q(status=Meal.ASK_BILL))
        context['requests_cards'] = Request.objects\
            .prefetch_related('diner', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(is_active=True)
        return context


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"
    model = Meal

    def get_context_data(self, **kwargs):
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        if (outlets.count() == 0):
            raise PermissionDenied
        limit = today_limit()
        context = super(HistoryView, self).get_context_data(**kwargs)
        context['meal_cards'] = Meal.objects\
            .prefetch_related('diner', 'orders', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(created__lte=limit[1], created__gte=limit[0])\
            .filter(status=Meal.INACTIVE)
        context['requests_cards'] = Request.objects\
            .prefetch_related('diner', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(created__lte=limit[1], created__gte=limit[0])\
            .filter(is_active=False)
        return context


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

    def post(self, request, *args, **kwargs):
        result = super(MenuView, self).post(request, *args, **kwargs)
        send_socketio_message(
            request.user.outlet_ids,
            ['refresh', 'menu', 'update'])
        return result


class MenuAddView(CreateView):
    form_class = DishCreateForm
    template_name = "bg_inventory/dish_form.html"
    success_url = "/staff/menu/"

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

    def post(self, request, *args, **kwargs):
        result = super(MenuAddView, self).post(request, *args, **kwargs)
        messages.success(self.request, 'Dish added.')
        send_socketio_message(
            request.user.outlet_ids,
            ['refresh', 'menu', 'add'])
        return result


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
            .prefetch_related('meals', 'meals__orders')\
            .filter(outlet__in=outlets)


class UserView(TemplateView):
    template_name = "bg_order/user.html"

    def get_context_data(self, **kwargs):
        context = super(UserView, self).get_context_data(**kwargs)
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        try:
            diner = User.objects.prefetch_related(
                'meals', 'meals__orders',
                'profile', 'notes').get(pk=self.kwargs['pk'])
        except User.DoesNotExist:
            raise Http404

        context['diner'] = diner
        context['reviews'] = Review.objects.filter(
            user=diner,
            outlet__in=outlets
        ).all()
        context['notes'] = Note.objects.filter(
            user=diner,
            outlet__in=outlets).all()
        return context


class ReportView(ListView):
    model = Meal
    template_name = "bg_order/report.html"

    def get_queryset(self):
        #filter queryset based on user's permitted outlet
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        if (outlets.count() == 0):
            raise PermissionDenied
        return super(ReportView, self).get_queryset()\
            .prefetch_related('diner', 'orders', 'table')\
            .filter(table__outlet__in=outlets, is_paid=True)
