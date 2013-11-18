from django.contrib import messages
from django.views.generic import ListView, TemplateView
from django.views.generic.edit import CreateView
from django.core.exceptions import PermissionDenied
from django.db.models import Q
from django.contrib.auth import get_user_model
from django.http import Http404

from guardian.shortcuts import get_objects_for_user

from bg_inventory.models import Dish, Outlet, Table, Review, Note, Category
from bg_order.models import Meal, Request

from bg_inventory.forms import DishCreateForm
from utils import send_socketio_message, today_limit

User = get_user_model()


class IndexView(TemplateView):
    template_name = "index.html"


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
        meals = Meal.objects\
            .prefetch_related('diner', 'orders', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(Q(status=Meal.ACTIVE) | Q(status=Meal.ASK_BILL))
        requests = Request.objects\
            .prefetch_related('diner', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(is_active=True)
        cards = list(meals) + list(requests)
        context["cards"] = sorted(cards,
                                  key=lambda card: card.count_down_start)
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
            .prefetch_related('diner', 'diner__meals', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(created__lte=limit[1], created__gte=limit[0])\
            .filter(status=Meal.INACTIVE).filter(is_paid=True)
        context['requests_cards'] = Request.objects\
            .prefetch_related('diner', 'diner__meals', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(created__lte=limit[1], created__gte=limit[0])\
            .filter(is_active=False)
        return context


class MenuView(ListView):
    model = Dish
    template_name = "bg_inventory/menu.html"

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

    def get_context_data(self, **kwargs):
        context = super(MenuView, self).get_context_data(**kwargs)
        context['categories'] = Category.objects.all()
        return context

    def get(self, request, *args, **kwargs):
        result = super(MenuView, self).get(request, *args, **kwargs)
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
        messages.success(self.request, 'Dish added')
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
            .prefetch_related('meals__diner',
                              'meals__diner__meals',
                              'meals', 'meals__orders')\
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
                'meals', 'meals__orders', 'meals__orders__dish',
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
            .prefetch_related('diner', 'orders', 'orders__dish', 'table')\
            .filter(table__outlet__in=outlets, is_paid=True)
