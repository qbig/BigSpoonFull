from django.contrib import admin
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import get_user_model
from guardian.admin import GuardedModelAdmin
from django.contrib.auth.admin import UserAdmin as AuthUserAdmin

User = get_user_model()

from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note
from bg_inventory.forms import BGUserCreationForm


class UserAdmin(AuthUserAdmin):

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': (
                'email', 'username', 'password1', 'password2')
        }),
    )
    add_form = BGUserCreationForm

    fieldsets = (
        (None, {'fields': ('email', 'username', 'password')}),
        (_('Personal info'), {'fields': (
            'first_name', 'last_name')}),
        (_('Permissions'), {'fields': (
            'is_active', 'is_staff', 'is_superuser', 'groups')}),
        (_('Important dates'), {'fields': (
            'last_login', 'date_joined')}),
    )
    list_display = ('email', 'username', 'is_staff', 'is_superuser',
                    'is_active')
    search_fields = ['email', 'username', 'first_name', 'last_name']
    readonly_fields = ['last_login', 'date_joined']


"""
Restaurant -> Outlet
            + Categories -> Dish -> Rating
            #Dish should be linked to restaurant first, rather than outlet.
Outlet -> Table, Review, Note
"""


class RestaurantAdmin(GuardedModelAdmin):
    search_fields = ['name']


class OutletAdmin(GuardedModelAdmin):
    raw_id_fields = ('restaurant',)
    search_fields = ['name', 'desc']


class TableAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet',)
    search_fields = ['name', 'desc']


class CategoryAdmin(GuardedModelAdmin):
    search_fields = ['name', 'desc']


class DishAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'categories')
    search_fields = ['name', 'desc', 'pos', 'price']


class RatingAdmin(GuardedModelAdmin):
    raw_id_fields = ('dish',)
    search_fields = ['score']


class ReviewAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet',)
    search_fields = ['score', 'feedback']


class NoteAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'user')
    search_fields = ['note']


admin.site.register(User, UserAdmin)
admin.site.register(Restaurant, RestaurantAdmin)
admin.site.register(Outlet, OutletAdmin)
admin.site.register(Table, TableAdmin)
admin.site.register(Category, CategoryAdmin)
admin.site.register(Dish, DishAdmin)
admin.site.register(Rating, RatingAdmin)
admin.site.register(Review, ReviewAdmin)
admin.site.register(Note, NoteAdmin)
