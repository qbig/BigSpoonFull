from django.contrib import admin
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import get_user_model
from guardian.admin import GuardedModelAdmin

User = get_user_model()

from bg_inventory.models import Restaurant


class UserAdmin(GuardedModelAdmin):
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        (_('Personal info'), {'fields': (
            'first_name', 'last_name')}),
        (_('Permissions'), {'fields': (
            'is_active', 'is_staff', 'is_superuser', 'groups')}),
        (_('Important dates'), {'fields': (
            'last_login', 'date_joined')}),
    )


class RestaurantAdmin(GuardedModelAdmin):
    pass

admin.site.register(User, UserAdmin)
admin.site.register(Restaurant, RestaurantAdmin)
