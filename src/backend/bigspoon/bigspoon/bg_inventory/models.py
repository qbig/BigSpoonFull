from django.utils.translation import ugettext_lazy as _
from django.utils import timezone
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin

from bg_inventory.managers import UserManager


class User(AbstractBaseUser, PermissionsMixin):
    """
    Custom User model, extending Django's AbstractBaseUser
    """

    # Django User required attribute
    email = models.EmailField(
        _('email'),
        max_length=255,
        unique=True,
        db_index=True,
        help_text=_('email as user primary id'),
    )
    first_name = models.CharField(
        _('first name'),
        max_length=30,
        blank=True,
        help_text=_('user first name'),
    )
    last_name = models.CharField(
        _('last name'),
        max_length=30,
        blank=True,
        help_text=_('user last name'),
    )
    date_joined = models.DateTimeField(
        _('date joined'),
        default=timezone.now,
        help_text=_('user joined time'),
    )
    is_staff = models.BooleanField(
        _('staff status'), default=False,
        help_text=_('Designates whether the user \
                    can log into django admin site.')
    )
    is_active = models.BooleanField(
        _('active'), default=False,
        help_text=_('Desingates whether the user \
                    is a valid user.')
    )

    USERNAME_FIELD = 'email'

    objects = UserManager()

    # Django User required method
    def get_full_name(self):
        """
        Returns the first_name plus the last_name, with a space in between
        """
        full_name = '%s %s' % (self.first_name, self.last_name)
        return full_name.strip()

    def get_short_name(self):
        """
        Returns the user email
        """
        return self.email

    def __unicode__(self):
        """
        Returns the user full name if any, else returns email
        """
        if self.first_name and self.last_name:
            return self.get_full_name()
        return self.email

    class Meta:
        verbose_name = _('user')
        verbose_name_plural = _('users')
