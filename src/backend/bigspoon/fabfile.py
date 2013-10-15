"""
BigSpoon CS3216 Final Project - Group 7
-> fab deploy
"""

import requests
import time

from fabric.api import run, env, sudo, hosts, cd
from fabric.colors import cyan, yellow, green, white, red


WORK_HOME = '/home/ec2-user/webapps/2013-final-project-7/src/backend/bigspoon/'
ENV_PATH = '/home/ec2-user/webapps/2013-final-project-7/src/backend/env/'
RUN_WITH_ENV = 'source ' + ENV_PATH + 'bin/activate && '
AWS_IP = '122.248.199.242'
SERVER = [AWS_IP]
env.user = 'ec2-user'
env.key_filename = '~/.ssh/bigspoon.pem'


def sanity_check(host, urls):
    time.sleep(5)
    print(yellow('Sanity check...\nPinging the following urls:\n'))
    for url in urls:
        time.sleep(1)
        status = requests.get(host+url).status_code
        if status == 200:
            print(white(host+url+' ...')+green('OK'))
        else:
            print(white(host+url+' ...')+red('ERROR'))
            return 1
            break


def restart_nginx():
    print(yellow('Restart Ngnix ...'))
    sudo("service nginx restart")


def restart_supervisord():
    print(yellow('Restart Supervisor ...'))
    sudo("service supervisord restart")


def install_requirements():
    print(yellow('Install requirements ...'))
    run(RUN_WITH_ENV+'pip install -r requirements.txt')


def create_db():
    print(yellow('Create new database ...'))
    run(RUN_WITH_ENV+'python manage.py flush')
    run(RUN_WITH_ENV+'python manage.py migrate')


def migrate_db():
    print(yellow('Migrate database ...'))
    run(RUN_WITH_ENV+'python manage.py schemamigration --auto bg_order')
    run(RUN_WITH_ENV+'python manage.py schemamigration --auto bg_inventory')
    run(RUN_WITH_ENV+'python manage.py migrate')


def collect_assets():
    print(yellow('Prepare assets ...'))
    run(RUN_WITH_ENV+'python manage.py collectstatic -c')
    run(RUN_WITH_ENV+'python manage.py compress')


@hosts(SERVER)
def deploy(*args):
    print(cyan('->  Connected to server'))
    with cd('%s' % WORK_HOME):
        print(yellow('Check out latest code ...'))
        run("git remote update && git reset --hard origin/master")
        install_requirements()
        if args:
            if 'newdb' in args:
                create_db()
            if 'migrate' in args:
                migrate_db()
            if 'assets' in args:
                collect_assets()
        restart_supervisord()
        if args:
            if 'nginx' in args:
                restart_nginx()
        sanity_check_status = sanity_check(
            'http://'+AWS_IP,
            ['/admin', '/staff/main', '/staff/menu']
        )
        if sanity_check_status == 1:
            print(red('\n-> Deployment error! wgx731 :('))
        else:
            print(green('\n-> Deployment succesful! wgx731 :)'))
