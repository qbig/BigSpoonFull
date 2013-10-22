from django.db import models
from django.utils.translation import ugettext_lazy as _

from bg_inventory.models import User, Table, Dish


class Request(models.Model):
    """
    Stores diner request information
    """
    WATER = 0
    WAITER = 1
    REQUEST_CHOICES = (
        (WATER, 'Ask for water'),
        (WAITER, 'Ask for waiter'),
    )

    diner = models.ForeignKey(User, related_name="requests")
    table = models.ForeignKey(Table, related_name="requests")
    request_type = models.IntegerField(
        max_length=1,
        choices=REQUEST_CHOICES,
    )
    is_active = models.BooleanField(
        default=True,
    )
    created = models.DateTimeField(
        auto_now_add=True,
        help_text=_('Request created time'),
    )
    finished = models.DateTimeField(
        help_text=_('Request finish time'),
        blank=True,
        null=True,
    )

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
    diner = models.ForeignKey(User, related_name="meals")
    table = models.ForeignKey(Table, related_name="meals")
    is_active = models.BooleanField(default=True)
    is_paid = models.BooleanField(default=False)
    created = models.DateTimeField(auto_now_add=True)
    modified = models.DateTimeField(auto_now=True)
    bill_time = models.DateTimeField(
        help_text=_('Time paid'),
        blank=True,
        null=True,
    )

    def __unicode__(self):
        meal_status = "Active" if self.is_active else "Inactive"
        meal_payment = "Paid" if self.is_paid else "Unpaid"

        return "(%s - %s) | %s | %s" % (self.table.outlet.name,
                                        self.table.name, meal_status,
                                        meal_payment)

    class Meta:
        verbose_name = _('meal')
        verbose_name_plural = _('meals')


class Order(models.Model):
    """
    Stores order information. An order is a quantity of a single dish.
    """
    meal = models.ForeignKey(Meal, related_name="orders")
    dish = models.ForeignKey(Dish, related_name="orders")
    quantity = models.IntegerField(
        default=0,
        help_text=_('Number of dishes ordered'),
    )

    def __unicode__(self):
        return "(%s - %s) %s | %s x%s" % (self.meal.table.outlet.name,
                                          self.meal.table.name,
                                          self.meal.diner.first_name,
                                          self.dish.name, self.quantity)

    class Meta:
        verbose_name = _('order')
        verbose_name_plural = _('orders')
