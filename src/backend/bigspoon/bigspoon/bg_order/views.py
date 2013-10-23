from django.contrib import messages
from django.views.generic import TemplateView, ListView
from django.views.generic.edit import CreateView

from extra_views import ModelFormSetView
from guardian.shortcuts import get_objects_for_user

from bg_inventory.models import Dish, Outlet, Table
from bg_order.models import Meal

from bg_inventory.forms import DishCreateForm


class MainView(ListView):
    template_name = "bg_order/main.html"
    model = Meal

    def get_queryset(self):
        return get_objects_for_user(self.request.user,
                                    "change_meal", Meal.objects.all())


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


class MenuAddView(CreateView):
    form_class = DishCreateForm
    template_name = "bg_inventory/dish_form.html"
    success_url = "/staff/menu/"

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
        outlet = get_objects_for_user(self.request.user, "change_outlet",
                                      Outlet.objects.all())[0]
        return super(TableView, self).get_queryset().filter(outlet=outlet).\
            prefetch_related('meal').prefetch_related('meal__order')


class UserView(TemplateView):
    template_name = "bg_order/user.html"


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
