from __future__ import absolute_import

from celery import task
from utils import send_socketio_message, send_user_feedback

@task
def send_socketio_message_async(chan_list, message_data):
	#[int(i) for i in chan_list.split("||")], [str(s) for s in message_data.split("||")]
	send_socketio_message([1,], ['refresh', 'meal', 'new'])

@task
def send_user_feedback_async(user, message_data):
	send_user_feedback(user, message_data)