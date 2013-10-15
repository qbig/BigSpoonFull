from django.contrib import admin
from bg_order.models import Request, Meal, Order


class RequestAdmin(admin.ModelAdmin):
    list_display = ['diner', 'table', 'request_type', 'is_active', 'created', 'finished']
    list_display_links = ('diner', 'table',)

class MealAdmin(admin.ModelAdmin):
    list_display = ['diner', 'table', 'is_active', 'is_paid']
    list_display_links = ('diner', 'table',)

class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'meal', 'get_diner', 'dish',
                    'quantity', 'created', 'modified', 'bill_time']

    list_display_links = ('meal','dish', 'get_diner')

    def get_diner(self, obj):
            return '%s'%(obj.meal.diner)
    get_diner.short_description = 'Diner'
    search_fields = ['meal_id']

admin.site.register(Request, RequestAdmin)
admin.site.register(Meal, MealAdmin)
admin.site.register(Order, OrderAdmin)