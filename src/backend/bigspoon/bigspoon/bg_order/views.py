from itertools import chain

from django.contrib import messages
from django.views.generic import ListView, TemplateView
from django.views.generic.edit import CreateView
from django.core.exceptions import PermissionDenied
from django.db.models import Q
from django.contrib.auth import get_user_model
from django.http import Http404
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger

from guardian.shortcuts import get_objects_for_user

from bg_inventory.models import Dish, Outlet, Table, Review, Note, Category
from bg_order.models import Meal, Request

from bg_inventory.forms import DishCreateForm
from utils import send_socketio_message, today_limit, natural_sort_key

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
            .prefetch_related('diner', 'orders',
                              'table', 'table__outlet')\
            .filter(table__outlet__in=outlets)\
            .filter(Q(status=Meal.ACTIVE) | Q(status=Meal.ASK_BILL))
        requests = Request.objects\
            .prefetch_related('diner', 'table', 'diner__meals',
                              'diner__meals__orders',
                              'table__outlet')\
            .filter(table__outlet__in=outlets)\
            .filter(is_active=True)
        context["cards"] = sorted(chain(meals, requests),
                                  key=lambda card: card.count_down_start)
        context["cards_num"] = meals.count() + requests.count()
        context["outlet"] = outlets[0]
        context["table_list"] = list(outlets[0].tables.all())
        self.request.session["cards_num"] = context["cards_num"]

        context['categories'] = list(outlets[0].categories.all())
        dishes = list(outlets[0].dishes.prefetch_related("categories").all())
        dic = {}
        for dish in dishes:
            try:
                if dish.categories.all()[0].id in dic:
                    dic[dish.categories.all()[0].id].append(dish)
                else:
                    dic[dish.categories.all()[0].id] = [dish,]
            except:
                pass
                
        context['dishes'] = dic
        return context

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        paginator = Paginator(context["cards"], 3)
        page = request.GET.get('page')
        try:
            context["cards"] = paginator.page(page)
        except PageNotAnInteger:
            context["cards"] = paginator.page(1)
        except EmptyPage:
            context["cards"] = paginator.page(paginator.num_pages)
        return self.render_to_response(context)


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
        tables = super(TableView, self).get_queryset()\
            .prefetch_related('meals__diner',
                              'meals__diner__meals',
                              'meals', 'meals__orders')\
            .filter(outlet__in=outlets).order_by("name")
        return sorted(tables, key=lambda t: natural_sort_key(t.name))

    def get_context_data(self, **kwargs):
        context = super(TableView, self).get_context_data(**kwargs)
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        if (outlets.count() == 0):
            raise PermissionDenied
        current_outlet = outlets[0]
        context["cards_num"] = self.request.session.get("cards_num")
        context['categories'] = list(current_outlet.categories.all())
        dishes = list(current_outlet.dishes.prefetch_related("categories").all())
        dic = {}
        for dish in dishes:
            try:
                if dish.categories.all()[0].id in dic:
                    dic[dish.categories.all()[0].id].append(dish)
                else:
                    dic[dish.categories.all()[0].id] = [dish,]
            except:
                pass
        context['dishes'] = dic
        return context


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
        context['current_meal'] = diner.meals.latest('created')
        context['current_table'] = context['current_meal'].table
        #context['table_list'] = list(context['current_table'].outlet.tables.all())
        context['reviews'] = Review.objects.filter(
            user=diner,
            outlet__in=outlets
        ).all()
        context['notes'] = Note.objects.filter(
            user=diner,
            outlet__in=outlets).all()
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
            .filter(status=Meal.INACTIVE).filter(is_paid=True).order_by('-created')
        context['requests_cards'] = Request.objects\
            .prefetch_related('diner', 'diner__meals', 'table')\
            .filter(table__outlet__in=outlets)\
            .filter(created__lte=limit[1], created__gte=limit[0])\
            .filter(is_active=False).order_by('-created')
        context["cards_num"] = self.request.session.get("cards_num")
        return context


class MenuView(ListView):
    model = Dish
    template_name = "bg_inventory/menu.html"
    for_outlet = None
    def get_queryset(self):
        #filter queryset based on user's permitted outlet
        outlets = get_objects_for_user(
            self.request.user,
            "change_outlet",
            Outlet.objects.all()
        )
        if (outlets.count() == 0):
            raise PermissionDenied
        self.for_outlet = outlets[0]
        return super(MenuView, self).get_queryset()\
            .prefetch_related('outlet', 'categories')\
            .filter(outlet__in=outlets)

    def get_context_data(self, **kwargs):
        context = super(MenuView, self).get_context_data(**kwargs)
        context['categories'] = self.for_outlet.categories.all()
        context["cards_num"] = self.request.session.get("cards_num")
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


class ReportView(ListView):
    model = Meal
    template_name = "bg_order/report.html"
    def get_context_data(self, **kwargs):
        context = super(ReportView, self).get_context_data(**kwargs)
        context["cards_num"] = self.request.session.get("cards_num")
        return context

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
