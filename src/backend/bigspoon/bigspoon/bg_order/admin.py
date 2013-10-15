from django.contrib import admin
from bg_order.models import Request, Meal, Order


@admin.register(Request)
class RequestAdmin(admin.ModelAdmin):
    pass

@admin.register(Meal)
class MealAdmin(admin.ModelAdmin):
    pass

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    pass