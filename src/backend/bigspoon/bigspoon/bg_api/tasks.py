from __future__ import absolute_import

from celery import task
from utils import send_socketio_message, send_user_feedback, today_limit
import datetime
from bg_order.models import Meal
from bg_inventory.models import User

@task
def send_socketio_message_async(chan_list, message_data):
	send_socketio_message([int(i) for i in str(chan_list).split("||")], 
		[str(s) for s in str(message_data).split("||")])

@task
def send_user_feedback_async(user, message_data):
	send_user_feedback(user, message_data)

@task.periodic_task(run_every=datetime.timedelta(seconds=60 * 15))
def remove_testing_meal():
    testers_emails = ['info@the loft.com.sg','ananias@theloft.com.sg', 'jay.tjk@gmail.com']
    testers = User.objects.filter(email__in=testers_emails)
    for meal in Meal.objects.filter(created__range=today_limit(), diner__in=testers):
        meal.delete()