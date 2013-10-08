#!/usr/bin/env python
from gevent import monkey
from socketio.server import SocketIOServer
import django.core.handlers.wsgi
import os

monkey.patch_all()

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "bigspoon.settings.dev")

PORT = 9000
application = django.core.handlers.wsgi.WSGIHandler()

if __name__ == '__main__':
    print 'Listening on http://127.0.0.1:%s and on port 10843 (flash policy server)' % PORT
    SocketIOServer(('', PORT), application, resource="socket.io").serve_forever()
