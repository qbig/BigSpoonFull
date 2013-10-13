from django.utils.translation import ugettext_lazy as _
from django.utils import timezone
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django_thumbs.db.models import ImageWithThumbsField
from django.utils.text import slugify

from bg_inventory.managers import UserManager


# helper methods
def _image_upload_path(instance, filename):
    return instance.get_upload_path(filename)


def _thumbnail_sizes(instance):
    return instance.get_thumbnail_size()


def _image_helptext(instance):
    return instance.get_image_helptext()


# model class
class BasicImage(models.Model):
    """
    Basic Image Model for store images
    """
    caption = models.CharField(
        _('caption'),
        max_length=300,
        blank=True,
        help_text=_('image caption')
    )
    image = ImageWithThumbsField(
        upload_to=_image_upload_path,
        sizes=_thumbnail_sizes,
        help_text=_image_helptext
    )

    def __unicode__(self):
        return "%s - %s" % (self.caption, self.image)


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


class RestaurantIcon(BasicImage):
    class Meta:
        proxy = True

    def get_upload_path(self, filename):
        fname, dot, extension = filename.rpartition('.')
        slug = slugify(fname)
        return '%s.%s' % (slug, extension)

    def get_thumbnail_size():
        return ((200, 200),)

    def get_image_helptext():
        return _('restaurant icon')


class Restaurant(models.Model):
    """
    Stores restaurant information
    """
    name = models.CharField(
        _('name'),
        max_length=128,
        unique=True,
        help_text=_('restaurant name')
    )
    desc = models.TextField(
        _('description'),
        blank=False,
        null=True,
        help_text=_('restaurant description')
    )
    icon = models.ForeignKey(RestaurantIcon)

    def __unicode__(self):
        """
        Returns the restaurant name
        """
        return slugify(self.name)

    class Meta:
        verbose_name = _('restaurant')
        verbose_name_plural = _('restaurants')
