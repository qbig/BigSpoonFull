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


# model class
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
        help_text=_('email as user identifier'),
    )
    username = models.CharField(
        _('username'),
        max_length=30,
        blank=True,
        help_text=_('username for internal use'),
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
        if self.username:
            return self.username
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


class Restaurant(models.Model):
    """
    Stores restaurant information
    """
    name = models.CharField(
        _('name'),
        max_length=255,
        help_text=_('restaurant name')
    )
    icon = ImageWithThumbsField(
        upload_to=_image_upload_path,
        sizes=((200, 200),),
        help_text=_('restaurant icon')
    )

    def get_upload_path(self, filename):
        fname, dot, extension = filename.rpartition('.')
        slug = slugify(self.name)
        return 'restaurant/icons/%s.%s' % (slug, extension)

    def __unicode__(self):
        """
        Returns the restaurant name
        """
        return self.name

    class Meta:
        verbose_name = _('restaurant')
        verbose_name_plural = _('restaurants')


class Outlet(models.Model):
    """
    Stores outlet information
    """
    restaurant = models.ForeignKey(Restaurant)
    name = models.CharField(
        _('name'),
        max_length=255,
        help_text=_('outlet name')
    )
    desc = models.TextField(
        _('description'),
        blank=False,
        null=True,
        help_text=_('outlet description')
    )

    def __unicode__(self):
        """
        Returns the outlet name
        """
        return self.name

    class Meta:
        verbose_name = _('outlet')
        verbose_name_plural = _('outlets')


class Table(models.Model):
    """
    Stores outlet table information
    """
    outlet = models.ForeignKey(Outlet)
    name = models.CharField(
        _('name'),
        max_length=255,
        unique=True,
        help_text=_('table name')
    )
    qrcode = models.CharField(
        _('qrcode'),
        max_length=255,
        help_text=_('table attached qrcode')
    )

    def __unicode__(self):
        """
        Returns the outlet and table name
        """
        return '%s - %s' % (self.outlet.name, self.name)

    class Meta:
        verbose_name = _('table')
        verbose_name_plural = _('tables')


class Category(models.Model):
    """
    Stores dish category information
    """
    name = models.CharField(
        _('name'),
        max_length=255,
        unique=True,
        help_text=_('category name')
    )
    desc = models.TextField(
        _('description'),
        blank=False,
        null=True,
        help_text=_('category description')
    )

    def __unicode__(self):
        """
        Returns the category name
        """
        return self.name

    class Meta:
        verbose_name = _('category')
        verbose_name_plural = _('categories')


class Dish(models.Model):
    """
    Stores outlet dish information
    """
    outlet = models.ForeignKey(Outlet)
    name = models.CharField(
        _('name'),
        max_length=255,
        help_text=_('outlet dish name')
    )
    pos = models.CharField(
        _('pos'),
        max_length=255,
        blank=False,
        null=True,
        help_text=_('outlet pos system dish id')
    )
    desc = models.TextField(
        _('description'),
        blank=False,
        null=True,
        help_text=_('outlet dish description')
    )
    start_time = models.TimeField(
        _('start time'),
        blank=False,
        null=False,
        help_text=_('dish start time'),
    )
    end_time = models.TimeField(
        _('end time'),
        blank=False,
        null=False,
        help_text=_('dish end time'),
    )
    price = models.DecimalField(
        max_digits=6,
        decimal_places=2,
    )
    photo = ImageWithThumbsField(
        upload_to=_image_upload_path,
        sizes=((640, 400),),
        help_text=_('dish photo')
    )
    categories = models.ManyToManyField(Category)

    def get_upload_path(self, filename):
        fname, dot, end = filename.rpartition('.')
        slug = slugify(self.name)
        return 'restaurant/dishes/%s/%s.%s' % (self.outlet.name, slug, end)

    def __unicode__(self):
        """
        Returns the dish name
        """
        return self.name

    class Meta:
        verbose_name = _('dish')
        verbose_name_plural = _('dishes')


class Rating(models.Model):
    """
    Stores dish rating information
    """
    user = models.ForeignKey(User)
    dish = models.ForeignKey(Dish)
    score = models.DecimalField(
        max_digits=2,
        decimal_places=1,
    )

    def __unicode__(self):
        """
        Returns the user and dish name
        """
        return "%s - %s" % (self.user.email, self.dish.name)

    class Meta:
        verbose_name = _('rating')
        verbose_name_plural = _('ratings')


class Review(models.Model):
    """
    Stores dish rating information
    """
    user = models.ForeignKey(User)
    outlet = models.ForeignKey(Outlet)
    score = models.DecimalField(
        max_digits=2,
        decimal_places=1,
    )
    feedback = models.TextField(
        _('feedback'),
        blank=False,
        null=True,
        help_text=_('user feedback for outlet')
    )

    def __unicode__(self):
        """
        Returns the user and outlet name
        """
        return "%s - %s" % (self.user.email, self.outlet.name)

    class Meta:
        verbose_name = _('review')
        verbose_name_plural = _('reviews')


class Note(models.Model):
    """
    Stores dish rating information
    """
    user = models.ForeignKey(User)
    outlet = models.ForeignKey(Outlet)
    note = models.TextField(
        _('note'),
        blank=False,
        null=True,
        help_text=_('outlet note for user')
    )

    def __unicode__(self):
        """
        Returns the outlet name and user name
        """
        return "%s's note for %s" % (self.outlet.name, self.user.email)

    class Meta:
        verbose_name = _('note')
        verbose_name_plural = _('notes')

from rest_framework.authtoken.models import Token
from django.dispatch import receiver
from django.db.models.signals import post_save


@receiver(post_save, sender=User)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)
