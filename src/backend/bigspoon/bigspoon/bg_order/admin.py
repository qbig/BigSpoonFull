from django.contrib import admin
from guardian.admin import GuardedModelAdmin
from bg_order.models import Request, Meal, Order
from import_export.admin import ImportExportModelAdmin

class RequestAdmin(GuardedModelAdmin):
    raw_id_fields = ('diner', 'table')
    list_display = ['diner', 'table', 'request_type', 'is_active', 'created',
                    'finished']
    list_display_links = ('diner', 'table',)
    search_fields = ['diner__first_name', 'diner__last_name']


class MealAdmin(GuardedModelAdmin, ImportExportModelAdmin):
    raw_id_fields = ('diner', 'table')
    list_display = ['id','email', 'diner', 'table', 'status', 'is_paid',
                    'created', 'modified', 'bill_time']
    list_display_links = ('diner', 'table',)
    def email(self, obj):
        return obj.diner.email

class OrderAdmin(GuardedModelAdmin):
    raw_id_fields = ('dish', 'meal')
    list_display = ['id', 'meal', 'get_diner', 'dish',
                    'quantity']
    list_display_links = ('meal', 'dish', 'get_diner')

    def get_diner(self, obj):
            return '%s' % (obj.meal.diner)
    get_diner.short_description = 'Diner'

admin.site.register(Request, RequestAdmin)
admin.site.register(Meal, MealAdmin)
admin.site.register(Order, OrderAdmin)
