from django.contrib import admin
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import get_user_model
from guardian.admin import GuardedModelAdmin
import copy

User = get_user_model()

from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note


search_fields_of = {}
search_fields_of["user"] = ['email', 'username', 'first_name', 'last_name']
search_fields_of["common"] = ['name'] #'desc'
search_fields_of["dish"] = search_fields_of["common"] + ['pos', 'price']

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
    search_fields = search_fields_of["user"]


"""
Restaurant -> Outlet
            + Categories -> Dish -> Rating
            #Currently restaurant is just a global grouping for outlets.
            #Dish should be linked to restaurant first, rather than outlet, since most outlets (in the same region) of the same restaurant will serve the same dishes.
Outlet -> Table, Review, Note
"""



class RestaurantAdmin(GuardedModelAdmin):
    search_fields = list(search_fields_of["common"])


class OutletAdmin(GuardedModelAdmin):
    raw_id_fields = ('restaurant',)
    search_fields = list(search_fields_of["common"])
    search_fields += ['restaurant__'+x for x in search_fields_of["common"]]


class TableAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet',)
    search_fields = list(search_fields_of["common"])
    search_fields += ['outlet__'+x for x in search_fields_of["common"]]


class CategoryAdmin(GuardedModelAdmin):
    search_fields = list(search_fields_of["common"])


class DishAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'categories')
    search_fields = list(search_fields_of["common"])
    search_fields += ['outlet__'+x for x in search_fields_of["common"]]
    search_fields += ['categories__'+x for x in search_fields_of["common"]]


class RatingAdmin(GuardedModelAdmin):
    raw_id_fields = ('dish',)
    search_fields = ['dish__'+x for x in search_fields_of["common"]]
    search_fields += ['user__'+x for x in search_fields_of["user"]]
    # search_fields = ['score']


class ReviewAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet',)
    search_fields = ['outlet__'+x for x in search_fields_of["common"]]
    search_fields += ['user__'+x for x in search_fields_of["user"]]
    # search_fields = ['score', 'feedback']


class NoteAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'user')
    search_fields = ['outlet__'+x for x in search_fields_of["common"]]
    search_fields += ['user__'+x for x in search_fields_of["user"]]
    # search_fields += ['note']


admin.site.register(User, UserAdmin)
admin.site.register(Restaurant, RestaurantAdmin)
admin.site.register(Outlet, OutletAdmin)
admin.site.register(Table, TableAdmin)
admin.site.register(Category, CategoryAdmin)
admin.site.register(Dish, DishAdmin)
admin.site.register(Rating, RatingAdmin)
admin.site.register(Review, ReviewAdmin)
admin.site.register(Note, NoteAdmin)
