"""Production settings and globals."""

from os import environ
from os.path import join, normpath

from common import *


########## EMAIL CONFIGURATION
# See: https://docs.djangoproject.com/en/dev/ref/settings/#email-backend
DEFAULT_FROM_EMAIL = 'no-reply@bigspoon.com'

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

# See: https://docs.djangoproject.com/en/dev/ref/settings/#email-host
EMAIL_HOST = environ.get('EMAIL_HOST', 'smtp.gmail.com')

# See: https://docs.djangoproject.com/en/dev/ref/settings/#email-host-password
EMAIL_HOST_PASSWORD = environ.get('EMAIL_HOST_PASSWORD', '')

# See: https://docs.djangoproject.com/en/dev/ref/settings/#email-host-user
EMAIL_HOST_USER = environ.get('EMAIL_HOST_USER', 'your_email@example.com')

# See: https://docs.djangoproject.com/en/dev/ref/settings/#email-port
EMAIL_PORT = environ.get('EMAIL_PORT', 587)

# See: https://docs.djangoproject.com/en/dev/ref/settings/#email-subject-prefix
EMAIL_SUBJECT_PREFIX = '[%s] ' % SITE_NAME

# See: https://docs.djangoproject.com/en/dev/ref/settings/#email-use-tls
EMAIL_USE_TLS = True

# See: https://docs.djangoproject.com/en/dev/ref/settings/#server-email
SERVER_EMAIL = EMAIL_HOST_USER
########## END EMAIL CONFIGURATION


########## DATABASE CONFIGURATION
import dj_database_url
DATABASES = {'default': dj_database_url.config()}
########## END DATABASE CONFIGURATION


########## CACHE CONFIGURATION
# See: https://docs.djangoproject.com/en/dev/ref/settings/#caches
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}
########## END CACHE CONFIGURATION

INSTALLED_APPS += (
    'raven.contrib.django.raven_compat',
    'djcelery',
)

########## STORAGE CONFIGURATION
# Not save media files on S3
DEFAULT_FILE_STORAGE = 'django.core.files.storage.FileSystemStorage'
########## END STORAGE CONFIGURATION

########## COMPRESSION CONFIGURATION
COMPRESS_URL = STATIC_URL

# See: http://django_compressor.readthedocs.org/en/latest/settings/#django.conf.settings.COMPRESS_OFFLINE
COMPRESS_OFFLINE = True

# See: http://django_compressor.readthedocs.org/en/latest/settings/#django.conf.settings.COMPRESS_CSS_FILTERS
COMPRESS_CSS_FILTERS += [
    'compressor.filters.cssmin.CSSMinFilter',
]

# See: http://django_compressor.readthedocs.org/en/latest/settings/#django.conf.settings.COMPRESS_JS_FILTERS
COMPRESS_JS_FILTERS += [
    'compressor.filters.jsmin.JSMinFilter',
]
########## END COMPRESSION CONFIGURATION

# Set your DSN value
RAVEN_CONFIG = {
    'dsn': 'https://e7d457d2b7374b298956b7b80c721786:97483dac32dd41fca95439a7fd7d70ee@app.getsentry.com/25559',
}


########## SECRET CONFIGURATION
# See: https://docs.djangoproject.com/en/dev/ref/settings/#secret-key
SECRET_KEY = environ.get('SECRET_KEY', SECRET_KEY)
########## END SECRET CONFIGURATION

########## ALLOWED HOSTS CONFIGURATION
# See: https://docs.djangoproject.com/en/dev/ref/settings/#allowed-hosts
ALLOWED_HOSTS = [
    '175.41.151.219',
    '54.254.12.170',
    '54.255.3.255',
    '54.255.0.38',
    '122.248.199.242',
    'bigspoon.biz',
    'www.bigspoon.biz',
    'ip-10-129-29-161.ap-southeast-1.compute.internal:8000',
]
########## END ALLOWED HOST CONFIGURATION

########## REST FRAMEWORK CONFIGURATION
########## END REST FRAMEWORK CONFIGURATION
BROKER_URL = 'amqp://bigspoon:bigspoon@localhost:5672/bghost'

CELERYBEAT_SCHEDULER = 'djcelery.schedulers.DatabaseScheduler'
CELERY_RESULT_BACKEND = 'redis://'
CELERY_TASK_RESULT_EXPIRES = 18000 
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = 'Asia/Singapore'
CELERY_ANNOTATIONS = {'*': {'rate_limit': '10/s'}}

DEBUG = True

# See: https://docs.djangoproject.com/en/dev/ref/settings/#template-debug
TEMPLATE_DEBUG = DEBUG
########## END DEBUG CONFIGURATION

