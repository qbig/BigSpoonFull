from django.db import models
from django.utils.translation import ugettext_lazy as _
from django.utils import timezone

from bg_inventory.models import User, Table, Dish

import time


class Request(models.Model):
    """
    Stores diner request information
    """
    WATER = 0
    WAITER = 1
    REQUEST_CHOICES_DIC = {
        WATER: 'Ask for water',
        WAITER: 'Ask for waiter',
    }
    REQUEST_CHOICES = (
        (WATER, 'Ask for water'),
        (WAITER, 'Ask for waiter'),
    )
    diner = models.ForeignKey(
        User,
        help_text=_('diner who create request'),
        related_name="requests"
    )
    table = models.ForeignKey(
        Table,
        help_text=_('table diner is sitting at when create request'),
        related_name="requests"
    )
    request_type = models.IntegerField(
        max_length=1,
        choices=REQUEST_CHOICES,
        help_text=_('request type, 0-WATER, 1-WAITER')
    )
    is_active = models.BooleanField(
        default=True,
    )
    created = models.DateTimeField(
        auto_now_add=True,
        help_text=_('request created time')
    )
    finished = models.DateTimeField(
        blank=True,
        null=True,
        help_text=_('request finish time')
    )
    note = models.TextField(
        _('note'),
        blank=True,
        help_text=_('request specific note')
    )

    @property
    def wait_time(self):
        diff = timezone.now() - self.created
        diffmod = divmod(diff.days * 86400 + diff.seconds, 60)
        return diffmod

    @property
    def used_time(self):
        diff = self.finished - self.created
        diffmod = divmod(diff.days * 86400 + diff.seconds, 60)
        return diffmod

    @property
    def count_down_start(self):
        timetuple = timezone.localtime(self.created).timetuple()
        timestamp = time.mktime(timetuple)
        return timestamp * 1000.0

    def __unicode__(self):
        request_status = "Active" if self.is_active else "Inactive"
        return "(%s) %s | %s" % (self.table.name, self.diner.first_name,
                                 request_status)

    class Meta:
        verbose_name = _('request')
        verbose_name_plural = _('requests')


# If there are any unpaid meals, users can still add orders to the meal,
# If all of the user's meals are paid, users add orders to a new Meal object
# Managers should be able to delete orders from the meal
class Meal(models.Model):
    """
    Stores meal information. A Meal is a set of Orders.
    """
    ACTIVE = 0
    INACTIVE = 1
    ASK_BILL = 2
    STATUS_CHOICES_DIC = {
        ACTIVE: 'active',
        INACTIVE: 'inactive',
        ASK_BILL: 'ask bill',
    }
    STATUS_CHOICES = (
        (ACTIVE, 'active'),
        (INACTIVE, 'inactive'),
        (ASK_BILL, 'ask bill'),
    )
    diner = models.ForeignKey(
        User,
        help_text=_('diner who create the meal'),
        related_name="meals"
    )
    table = models.ForeignKey(
        Table,
        help_text=_('table diner is sitting at when create meal'),
        related_name="meals"
    )
    status = models.IntegerField(
        max_length=1,
        choices=STATUS_CHOICES,
        default=ACTIVE,
        help_text=_('status: 0-ACTIVE, 1-INACTIVE, 2-ASK_BILL')
    )
    is_paid = models.BooleanField(
        help_text=_('whether the meal is closed'),
        default=False
    )
    created = models.DateTimeField(
        help_text=_('time when meal is created'),
        auto_now_add=True
    )
    modified = models.DateTimeField(
        help_text=_('time when meal is last updated'),
        blank=True,
        null=True,
    )
    bill_time = models.DateTimeField(
        help_text=_('time when meal is paid'),
        blank=True,
        null=True,
    )
    note = models.TextField(
        _('note'),
        blank=True,
        help_text=_('meal specific note')
    )

    @property
    def wait_time(self):
        diff = timezone.now() - self.modified
        diffmod = divmod(diff.days * 86400 + diff.seconds, 60)
        return diffmod

    @property
    def used_time(self):
        if (self.bill_time):
            diff = self.bill_time - self.created
        else:
            diff = self.modified - self.created
        diffmod = divmod(diff.days * 86400 + diff.seconds, 60)
        return diffmod

    @property
    def count_down_start(self):
        timetuple = timezone.localtime(self.modified).timetuple()
        timestamp = time.mktime(timetuple)
        return timestamp * 1000.0

    def get_meal_spending(self):
        meal_spending = 0
        for order in self.orders.all():
            meal_spending += order.dish.price * order.quantity
        return meal_spending

    def get_created(self):
        return self.created.strftime('%d %b %Y')

    def __unicode__(self):
        meal_payment = "Paid" if self.is_paid else "Unpaid"

        return "(%s - %s) | %s | %s" % (self.table.outlet.name,
                                        self.table.name,
                                        self.STATUS_CHOICES_DIC[self.status],
                                        meal_payment)

    class Meta:
        verbose_name = _('meal')
        verbose_name_plural = _('meals')


class Order(models.Model):
    """
    Stores order information. An order is a quantity of a single dish.
    """
    meal = models.ForeignKey(
        Meal,
        help_text=_('belong to meal'),
        related_name="orders"
    )
    dish = models.ForeignKey(
        Dish,
        help_text=_('ordered dish'),
        related_name="orders"
    )
    quantity = models.IntegerField(
        default=0,
        help_text=_('number of dishes ordered'),
    )

    def get_order_spending(self):
        return self.dish.price * self.quantity

    def __unicode__(self):
        return "(%s - %s) %s | %s x %s" % (
            self.meal.table.outlet.name,
            self.meal.table.name,
            self.meal.diner.get_full_name(),
            self.dish.name, self.quantity
        )

    class Meta:
        verbose_name = _('order')
        verbose_name_plural = _('orders')


from django.dispatch import receiver
from django.db.models.signals import post_save
from guardian.shortcuts import assign_perm, get_users_with_perms


@receiver(post_save, sender=Request)
def post_request_creation(sender, instance=None, created=False, **kwargs):
    if created:
        assign_perm('change_request', instance.diner, instance)
        for u in get_users_with_perms(instance.table.outlet):
            assign_perm('change_request', u, instance)


@receiver(post_save, sender=Meal)
def post_meal_creation(sender, instance=None, created=False, **kwargs):
    if created:
        assign_perm('change_meal', instance.diner, instance)
        for u in get_users_with_perms(instance.table.outlet):
            assign_perm('change_meal', u, instance)
