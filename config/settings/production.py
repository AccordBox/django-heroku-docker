from __future__ import absolute_import, unicode_literals

from .base import *

env = os.environ.copy()

import dj_database_url

DEBUG = False

SECRET_KEY = os.environ.get('SECRET_KEY', default='5+f#!xn=hj^u#=cr9@pz@@5cf7bqf0ymy=8uyfpx_zvxpght3=')

STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

ALLOWED_HOSTS = ['*']

if "DATABASE_URL" in env:
    DATABASES['default'] = dj_database_url.config(conn_max_age=600, ssl_require=True)

try:
    from .local import *
except ImportError:
    pass
