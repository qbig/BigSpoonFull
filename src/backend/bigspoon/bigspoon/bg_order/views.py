from django.contrib import messages
from django.views.generic import TemplateView
from django.views.generic import ListView
from django.views.generic.edit import CreateView

from extra_views import ModelFormSetView

from bg_inventory.models import Dish, Outlet
from bg_order.models import Meal
from bg_inventory.forms import DishCreateForm
from guardian.shortcuts import get_objects_for_user


class MainView(ListView):
    template_name = "bg_order/main.html"
    model = Meal

    def get_queryset(self):
        return get_objects_for_user(self.request.user,
                                    "change_meal", Meal.objects.all())


class MenuView(ModelFormSetView):
    template_name = "bg_order/menu.html"
    model = Dish
    fields = ['name', 'desc', 'price', 'pos', 'quantity', 'photo']
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
        temp = super(MenuView, self).get_context_data(**kwargs)
        return temp

    def get(self, request, *args, **kwargs):
        temp = super(MenuView, self).get(request, *args, **kwargs)
        return temp


class MenuAddView(CreateView):
    form_class = DishCreateForm
    template_name = "bg_inventory/dish_form.html"
    success_url = "/staff/menu/"

    #get outlet based on staff logged in
    def formset_valid(self, formset):
        print("Menu add Form Valid")
        return super(MenuAddView, self).formset_valid(formset)

    def formset_invalid(self, formset):
        print("Menu add Form invalid")
        return super(MenuAddView, self).formset_invalid(formset)


class TableView(TemplateView):
    template_name = "bg_order/tables.html"


class UserView(TemplateView):
    template_name = "bg_order/user.html"


class HistoryView(TemplateView):
    template_name = "bg_order/history.html"


class ReportView(TemplateView):
    template_name = "bg_order/report.html"
