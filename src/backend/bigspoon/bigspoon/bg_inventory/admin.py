from django.contrib import admin
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import get_user_model
from guardian.admin import GuardedModelAdmin

User = get_user_model()

from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note


class UserAdmin(admin.ModelAdmin):
    fieldsets = (
        (None, {'fields': ('email', 'username', 'password')}),
        (_('Personal info'), {'fields': (
            'first_name', 'last_name')}),
        (_('Permissions'), {'fields': (
            'is_active', 'is_staff', 'is_superuser', 'groups')}),
        (_('Important dates'), {'fields': (
            'last_login', 'date_joined')}),
    )
    search_fields = ['email', 'username', 'first_name', 'last_name']


"""
Restaurant -> Outlet
            + Categories -> Dish -> Rating
            #Dish should be linked to restaurant first, rather than outlet.
Outlet -> Table, Review, Note
"""

class RestaurantAdmin(GuardedModelAdmin):
    search_fields = ['name']
    pass


class OutletAdmin(GuardedModelAdmin):
    raw_id_fields = ('restaurant',)
    search_fields = ['name', 'desc']


class TableAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet',)
    search_fields = ['name', 'desc']


class CategoryAdmin(GuardedModelAdmin):
    search_fields = ['name', 'desc']
    pass


class DishAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'categories')
    search_fields = ['name', 'desc', 'pos', 'price'] #outlet, categories


class RatingAdmin(GuardedModelAdmin):
    raw_id_fields = ('dish',)
    search_fields = ['score'] #user, dish


class ReviewAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet',)
    search_fields = ['score', 'feedback'] #user, outlet


class NoteAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'user')
    search_fields = ['note'] #user, outlet


admin.site.register(User, UserAdmin)
admin.site.register(Restaurant, RestaurantAdmin)
admin.site.register(Outlet, OutletAdmin)
admin.site.register(Table, TableAdmin)
admin.site.register(Category, CategoryAdmin)
admin.site.register(Dish, DishAdmin)
admin.site.register(Rating, RatingAdmin)
admin.site.register(Review, ReviewAdmin)
admin.site.register(Note, NoteAdmin)
