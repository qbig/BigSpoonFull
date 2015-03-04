"""Production settings and globals."""


from os import environ

from S3 import CallingFormat

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

########## STORAGE CONFIGURATION
# See: http://django-storages.readthedocs.org/en/latest/index.html
INSTALLED_APPS += (
    'storages',
    'raven.contrib.django.raven_compat',
)

# Not save media files on S3
DEFAULT_FILE_STORAGE = 'django.core.files.storage.FileSystemStorage'
# See: http://django-storages.readthedocs.org/en/latest/backends/amazon-S3.html#settings
STATICFILES_STORAGE = 'storages.backends.s3boto.S3BotoStorage'

# See: http://django-storages.readthedocs.org/en/latest/backends/amazon-S3.html#settings
AWS_CALLING_FORMAT = CallingFormat.SUBDOMAIN

# See: http://django-storages.readthedocs.org/en/latest/backends/amazon-S3.html#settings
AWS_ACCESS_KEY_ID = environ.get('AWS_ACCESS_KEY_ID', '')
AWS_SECRET_ACCESS_KEY = environ.get('AWS_SECRET_ACCESS_KEY', '')
AWS_STORAGE_BUCKET_NAME = environ.get('AWS_STORAGE_BUCKET_NAME', '')
AWS_AUTO_CREATE_BUCKET = True
AWS_QUERYSTRING_AUTH = False

# AWS cache settings, don't change unless you know what you're doing:
AWS_EXPIRY = 60 * 60 * 24 * 7
AWS_HEADERS = {
    'Cache-Control': 'max-age=%d, s-maxage=%d, must-revalidate'
    % (AWS_EXPIRY, AWS_EXPIRY)
}

########## END STORAGE CONFIGURATION


########## COMPRESSION CONFIGURATION
COMPRESS_URL = 'https://%s.s3.amazonaws.com/' % AWS_STORAGE_BUCKET_NAME
STATIC_URL = COMPRESS_URL

# See: http://django_compressor.readthedocs.org/en/latest/settings/#django.conf.settings.COMPRESS_OFFLINE
COMPRESS_OFFLINE = True

# See: http://django_compressor.readthedocs.org/en/latest/settings/#django.conf.settings.COMPRESS_STORAGE
COMPRESS_STORAGE = STATICFILES_STORAGE

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
    '54.255.17.69',
    '54.255.3.255',
    '54.255.66.101',
    '122.248.199.242',
    'bigspoon.biz',
    'www.bigspoon.biz',
    'ip-10-129-29-161.ap-southeast-1.compute.internal:8000',
]
########## END ALLOWED HOST CONFIGURATION

########## REST FRAMEWORK CONFIGURATION
########## END REST FRAMEWORK CONFIGURATION
