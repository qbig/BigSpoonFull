from django.contrib import admin
from bg_order.models import Request, Meal, Order


class RequestAdmin(admin.ModelAdmin):
    pass

class MealAdmin(admin.ModelAdmin):
    pass

class OrderAdmin(admin.ModelAdmin):
    pass

admin.site.register(Request, RequestAdmin)
admin.site.register(Meal, MealAdmin)
admin.site.register(Order, OrderAdmin)