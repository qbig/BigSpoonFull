from django.contrib import admin
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import get_user_model
from django.conf.urls import patterns
from guardian.admin import GuardedModelAdmin
from django.contrib.auth.admin import UserAdmin as AuthUserAdmin

User = get_user_model()

from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note, Profile
from bg_inventory.forms import BGUserCreationForm
from bg_inventory.utils import import_dish_csv


search_fields_of = {}
search_fields_of["user"] = ['email', 'username', 'first_name', 'last_name']
search_fields_of["common"] = ['name']
search_fields_of["dish"] = search_fields_of["common"] + ['pos', 'price']


class UserAdmin(AuthUserAdmin):
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2')
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
    search_fields = search_fields_of["user"]
    readonly_fields = ['last_login', 'date_joined']


class ProfileAdmin(GuardedModelAdmin):
    raw_id_fields = ('user', 'favourite_categories')


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


class RatingAdmin(GuardedModelAdmin):
    raw_id_fields = ('dish',)
    search_fields = ['dish__'+x for x in search_fields_of["common"]]
    search_fields += ['user__'+x for x in search_fields_of["user"]]


class ReviewAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet',)
    search_fields = ['outlet__'+x for x in search_fields_of["common"]]
    search_fields += ['user__'+x for x in search_fields_of["user"]]


class NoteAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'user')
    search_fields = ['outlet__'+x for x in search_fields_of["common"]]
    search_fields += ['user__'+x for x in search_fields_of["user"]]


class DishAdmin(GuardedModelAdmin):
    raw_id_fields = ('outlet', 'categories')
    search_fields = list(search_fields_of["common"])
    search_fields += ['outlet__'+x for x in search_fields_of["common"]]
    search_fields += ['categories__'+x for x in search_fields_of["common"]]
    change_list_template = 'admin/dish-changelist.html'

    def get_urls(self):
        urls = super(DishAdmin, self).get_urls()
        return patterns(
            '',
            (r'^import/$', self.admin_site.admin_view(import_dish_csv)))\
            + urls

admin.site.register(User, UserAdmin)
admin.site.register(Profile, ProfileAdmin)
admin.site.register(Restaurant, RestaurantAdmin)
admin.site.register(Outlet, OutletAdmin)
admin.site.register(Table, TableAdmin)
admin.site.register(Category, CategoryAdmin)
admin.site.register(Dish, DishAdmin)
admin.site.register(Rating, RatingAdmin)
admin.site.register(Review, ReviewAdmin)
admin.site.register(Note, NoteAdmin)
