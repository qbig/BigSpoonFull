from django.utils.translation import ugettext_lazy as _
from django.utils import timezone
from django.db import models
from django.db.models import Avg
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django_thumbs.db.models import ImageWithThumbsField
from django.utils.text import slugify
from guardian.shortcuts import get_objects_for_user
from cache_utils.decorators import cached
from bg_inventory.managers import UserManager

from jsonfield import JSONField

import urllib
import hashlib


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
        help_text=_('facebook username or facebook id'),
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
        _('staff status'),
        default=False,
        help_text=_('Designates whether the user \
                    can log into django admin site.')
    )
    is_active = models.BooleanField(
        _('active'),
        default=False,
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
        if self.first_name and self.last_name:
            full_name = '%s %s' % (self.first_name, self.last_name)
        elif self.first_name:
            full_name = self.first_name
        else:
            full_name = self.email
        return full_name.strip()

    def get_total_spending(self):
        """
        Returns total sum of all orders of all meals.
        """
        total_spending = 0
        for meal in self.meals.all():
            total_spending += meal.get_meal_spending()
        return total_spending
    
    
    def get_recent_outlet_meals(self):
        """
        Returns meals from the most recent outlet.
        """
        @cached(60*5)
        def get_meals(pk):
            if self.meals.count() > 0:
                tables = self.meals.latest('created').table.outlet.tables.all()
                return self.meals.filter(table__in=tables)
            else:
                return []
        return get_meals(self.pk)

    
    def get_spending_for_recent_outlet(self):
        """
        Returns sum of all orders of meals for given outlet.
        """
        @cached(60*5)
        def get_spending(pk):
            total_spending = 0
            recent_meals = self.get_recent_outlet_meals()

            if not recent_meals:
                return total_spending
        
            for meal in recent_meals:
                total_spending += meal.get_meal_spending()
            return total_spending
        return get_spending(self.pk)

    
    def get_num_of_visits_for_recent_outlet(self):
        """
        Returns num of visits for given outlet.
        """
        @cached(60*5)
        def get_visits_num(pk):
            recent_meals = self.get_recent_outlet_meals()
            if not recent_meals:
                return 0
            else:
                return recent_meals.count()
        return get_visits_num(self.pk)

    
    def get_average_spending_for_recent_outlet(self):

        @cached(60*5)
        def get_avg_spending(pk):
            total_spending = self.get_spending_for_recent_outlet()
            num_of_visits = self.get_num_of_visits_for_recent_outlet()
            if num_of_visits != 0:
                return "{0:.2f}".format(total_spending / num_of_visits)
            else:
                return 0
        return get_avg_spending(self.pk)


    
    def get_average_spending(self):
        """
        Returns average of all orders of all meals of this user.
        """
        @cached(60*60*2)
        def get_avg(pk):
            num_meals = self.meals.count()
            if num_meals == 0:
                return 0
                total_spending = self.get_total_spending()
                #round to two decimal places
            return int(total_spending / num_meals * 100) / 100.0
        return get_avg(self.pk)

    def get_short_name(self):
        """
        Returns the user email
        """
        if self.username:
            return self.username
        return self.email

    # user attributes
    @property
    def avatar_url(self):
        if (self.username):
            return "https://graph.facebook.com/%s/picture?type=%s" % (
                self.username, 'small')
        return "http://www.gravatar.com/avatar/%s?%s" % (
            hashlib.md5(self.email.lower()).hexdigest(),
            urllib.urlencode({'d': 'mm', 's': str(50)})
        )

    @property
    def avatar_url_large(self):
        if (self.username):
            return "https://graph.facebook.com/%s/picture?type=%s" % (
                self.username, 'large')
        return "http://www.gravatar.com/avatar/%s?%s" % (
            hashlib.md5(self.email.lower()).hexdigest(),
            urllib.urlencode({'d': 'mm', 's': str(180)})
        )

    @property
    def outlet_ids(self):
        outlets = get_objects_for_user(
            self,
            "change_outlet",
            Outlet.objects.all()
        )
        # NOTE: convert long to int may fall in future
        return [int(o.id) for o in outlets]

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
        help_text=_('category description')
    )

    # is_list_view_only = models.BooleanField(
    #     _('list view only'),
    #     default=False,
    #     help_text=_('In bigspoon app, only show this category as list view')
    # )

    def __unicode__(self):
        """
        Returns the category name
        """
        return self.name

    class Meta:
        verbose_name = _('category')
        verbose_name_plural = _('categories')


class Profile(models.Model):
    """
    Stores user profile information (e.g. gender, favourite category)
    """

    # gender types
    GENDER_TYPES_DIC = {
        'M': 'Male',
        'F': 'Female',
    }
    GENDER_TYPES = (
        ('M', 'Male'),
        ('F', 'Female'),
    )

    # yes no choices
    YES_NO_CHOICES_DIC = {
        'Y': 'Yes',
        'N': 'No',
    }
    YES_NO_CHOICES = (
        ('Y', 'Yes'),
        ('N', 'No'),
    )

    user = models.OneToOneField(
        User,
        help_text=_('user'),
    )
    gender = models.CharField(
        _('gender'),
        max_length=1,
        choices=GENDER_TYPES,
        default='M',
        help_text=_('user gender information'),
    )
    is_vegetarian = models.CharField(
        _('vegeteration'),
        max_length=1,
        choices=YES_NO_CHOICES,
        default='N',
        help_text=_('whether user is vegetarian'),
    )
    is_muslim = models.CharField(
        _('muslim'),
        max_length=1,
        choices=YES_NO_CHOICES,
        default='N',
        help_text=_('whether user is muslim'),
    )
    allergies = models.TextField(
        _('allergies'),
        blank=True,
        help_text=_('user allergies (e.g. peanut)')
    )
    favourite_categories = models.ManyToManyField(
        Category,
        blank=True,
        help_text=_('user favourite categories'),
        related_name='prefered_user_profiles',
    )

    def __unicode__(self):
        """
        Returns user name and gender
        """
        return "%s - %s" % (self.user, self.gender)

    def get_favourite_categories(self):
        favourites = ""
        for category in self.favourite_categories.all():
            favourites += (category.name + ", ")
        return favourites

    class Meta:
        verbose_name = _('profile')
        verbose_name_plural = _('profiles')


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
        return 'restaurant/icons/%s/%s.%s' % (self.id, slug, extension)

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
    restaurant = models.ForeignKey(
        Restaurant,
        help_text=_('belong to restaurant'),
        related_name='outlets',
    )

    name = models.CharField(
        _('name'),
        max_length=255,
        help_text=_('outlet name')
    )
    discount = models.CharField(
        _('discount'),
        max_length=30,
        blank=True,
        help_text=_('outlet discount')
    )
    phone = models.CharField(
        _('phone'),
        max_length=30,
        help_text=_('outlet contact phone')
    )
    address = models.TextField(
        _('address'),
        help_text=_('outlet address')
    )
    lat = models.CharField(
        _('latitude'),
        max_length=20,
        blank=True,
        help_text=_('outlet latitude')
    )
    lng = models.CharField(
        _('longitude'),
        max_length=20,
        blank=True,
        help_text=_('outlet longitude')
    )
    opening = models.TextField(
        _('open hours'),
        help_text=_('outlet opening hours')
    )
    threshold = models.IntegerField(
        _('threshold'),
        default=10,
        help_text=_('service time threshold'),
    )

    refresh_interval = models.IntegerField(
        _('refresh interval'),
        default=30,
        help_text=_('refresh interval for dashboard'),
    )

    location_diameter = models.DecimalField(
        _('location checking diameter'),
        max_digits=4,
        decimal_places=0,
        default="50",
        help_text=_('location diameter checking'),
    )
    is_active = models.BooleanField(
        default=False,
    )
    gst = models.DecimalField(
        _('gst'),
        max_digits=3,
        decimal_places=2,
        default="0.07",
        help_text=_('goods and services tax'),
    )
    scr = models.DecimalField(
        _('scr'),
        max_digits=3,
        decimal_places=2,
        default="0.10",
        help_text=_('service charge rate'),
    )

    categories = models.ManyToManyField(
        Category,
        blank=True,
        help_text=_('categories of food offered'),
        related_name='from_outlet',
    )

    is_by_default_photo_menu = models.BooleanField(
        default=False,
    )

    is_auto_send_to_POS = models.BooleanField(
        default=False,
    )

    request_for_water_enabled = models.BooleanField(
        default=True,
    )

    water_popup_text = models.TextField(
        _('water text'),
        help_text=_('water text'),
        blank=True
    )

    ask_for_bill_enabled = models.BooleanField(
        default=True,
    )

    bill_popup_text = models.TextField(
        _('bill text'),
        help_text=_('Bill popup text'),
        blank=True
    )

    default_dish_photo = ImageWithThumbsField(
        upload_to=_image_upload_path,
        blank=True,
        null=True,
        sizes=((640, 400), (320, 200)),
        help_text=_('dish photo')
    )

    def get_upload_path(self, filename):
        fname, dot, end = filename.rpartition('.')
        slug = slugify(self.name)
        return 'restaurant/dishes/%s/%s/%s.%s' % (
            self.name, self.id, slug, end)

    def __unicode__(self):
        """
        Returns the outlet name
        """
        return self.name

    class Meta:
        verbose_name = _('outlet')
        verbose_name_plural = _('outlets')


class CategorySequence(models.Model):
    """
    Store sequence information of a category for a outlet
    """
    order_index = models.PositiveIntegerField(
        default=(lambda: Category.objects.count() + 1),
        help_text="The order you want this category to appear."
    )

    outlet = models.ForeignKey(
        Outlet,
        help_text=_('belong to outlet'),
        related_name='category_orders',
    )

    for_category = models.ForeignKey(
        Category,
        help_text=_('for category'),
        related_name='occur_sequences'
    )

    
class Table(models.Model):
    """
    Stores outlet table information
    """
    outlet = models.ForeignKey(
        Outlet,
        help_text=_('belong to outlet'),
        related_name='tables',
    )
    name = models.CharField(
        _('name'),
        max_length=255,
        unique=False,
        help_text=_('table name')
    )
    code = models.CharField(
        _('code'),
        max_length=255,
        help_text=_('table code')
    )

    is_for_take_away = models.BooleanField(
        _('for take away or not'),
        default=False,
        help_text=_('Designates whether the table \
                    is a dummy one for takeaway only.')
    )

    def __unicode__(self):
        """
        Returns the outlet and table name
        """
        return '%s - %s' % (self.outlet.name, self.name)

    def get_table_spending(self):
        """
        Returns a table's total spending
        """
        total = 0
        meals = self.meals.all()
        for meal in meals:
            total += meal.get_meal_spending()
        return total

    class Meta:
        verbose_name = _('table')
        verbose_name_plural = _('tables')


class Dish(models.Model):
    """
    Stores outlet dish information
    """
    QUANTITY_CHOICES = [(i, i) for i in xrange(0, 51, 10)]
    QUANTITY_CHOICES += [(100, 100)]

    outlet = models.ForeignKey(
        Outlet,
        help_text=_('belong to outlet'),
        related_name='dishes',
    )
    name = models.CharField(
        _('name'),
        max_length=255,
        help_text=_('outlet dish name')
    )
    pos = models.CharField(
        _('pos'),
        max_length=255,
        db_index=True,
        help_text=_('outlet pos system dish id')
    )
    desc = models.TextField(
        _('description'),
        help_text=_('outlet dish description')
    )
    start_time = models.TimeField(
        _('start time'),
        help_text=_('dish start time'),
    )
    end_time = models.TimeField(
        _('end time'),
        help_text=_('dish end time'),
    )
    price = models.DecimalField(
        max_digits=6,
        decimal_places=2,
    )
    quantity = models.IntegerField(
        default=0,
        help_text=_('dish stock'),
        choices=QUANTITY_CHOICES,
    )
    photo = ImageWithThumbsField(
        upload_to=_image_upload_path,
        blank=True,
        null=True,
        sizes=((640, 400), (320, 200)),
        help_text=_('dish photo')
    )
    categories = models.ManyToManyField(
        Category,
        blank=True,
        help_text=_('belong to category'),
        related_name='dishes',
    )

    custom_order_json = JSONField(
        blank=True,
        null=True,)

    can_be_customized = models.BooleanField(
        default=False,
    )

    is_active = models.BooleanField(
        default=True,
    )

    def get_upload_path(self, filename):
        fname, dot, end = filename.rpartition('.')
        slug = slugify(self.name)
        return 'restaurant/dishes/%s/%s/%s.%s' % (
            self.outlet.name, self.id, slug, end)

    def get_average_rating(self):
        average_rating = self.ratings.all().\
            aggregate(Avg('score'))['score__avg']

        if average_rating is None:
            return -1
        else:
            return int(average_rating)

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
    user = models.ForeignKey(
        User,
        help_text=_('rate user'),
        related_name='ratings',
    )
    dish = models.ForeignKey(
        Dish,
        help_text=_('rated dish'),
        related_name='ratings',
    )
    score = models.DecimalField(
        max_digits=2,
        decimal_places=1,
        default='0.0',
    )

    def __unicode__(self):
        """
        Returns the user and dish name
        """
        return "%s - %s" % (self.user.email, self.dish.name)

    class Meta:
        verbose_name = _('rating')
        verbose_name_plural = _('ratings')
        unique_together = ("dish", "user")


class Review(models.Model):
    """
    Stores dish rating information
    """
    user = models.ForeignKey(
        User,
        help_text=_('review user'),
        related_name='reviews',
    )
    outlet = models.ForeignKey(
        Outlet,
        help_text=_('reviewed outlet'),
        related_name='reviews',
    )
    feedback = models.TextField(
        _('feedback'),
        help_text=_('feedback text')
    )

    def __unicode__(self):
        """
        Returns the user and outlet name
        """
        return "%s - %s" % (self.user.email, self.outlet.name)

    class Meta:
        verbose_name = _('review')
        verbose_name_plural = _('reviews')
        unique_together = ("outlet", "user")


class Note(models.Model):
    """
    Stores dish rating information
    """
    user = models.ForeignKey(
        User,
        help_text=_('note for user'),
        related_name='notes',
    )
    outlet = models.ForeignKey(
        Outlet,
        help_text=_('note from outlet'),
        related_name='notes',
    )
    content = models.TextField(
        _('note content'),
        help_text=_('note content text')
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
def post_user_creation(sender, instance=None, created=False, **kwargs):
    if created:
        # create token
        Token.objects.create(user=instance)
        # create profile
        Profile.objects.create(user=instance)
