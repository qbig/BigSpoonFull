BigSpoon Django Backend Setup Instructions
------

### ssh config

```
Host 3216-final
    HostName 122.248.199.242
    User ec2-user
    IdentityFile ~/.ssh/bigspoon.pem
```

### server environment variables

needed on production server but not on local dev environment
+ `DJANGO_SETTINGS_MODULE`
+ `EMAIL_HOST`
+ `EMAIL_HOST_PASSWORD`
+ `EMAIL_HOST_USER`
+ `EMAIL_PORT`
+ `AWS_ACCESS_KEY_ID`
+ `AWS_SECRET_ACCESS_KEY`
+ `AWS_STORAGE_BUCKET_NAME`
+ `SECRET_KEY`
+ `DATABASE_URL`

### setup virtualenv and install requirements

1. install [`virtualenv`](http://www.virtualenv.org/en/latest/#installation) for python
2. `virtualenv env` (make sure you are at the same folder where this README file is at)
3. `source env/bin/activate`
4. `pip install -r bigspoon/reqs/dev.txt`

### bash alias

Put blow code in your ~/.bashrc file:
`BIGSPOON_BACKEND=(Path to your backend folder)`
`alias workon_bg='cd $BIGSPOON_BACKEND; source env/bin/activate;'`

### start server locally
Make sure you are at folder where `manage.py` file is in
Migrate Database:
`python manage.py syncdb`
`python manage.py migrate`
Start normal server:
`python manage.py runserver` - running at localhost:8000
Start gevent socket server:
`python run.py` - running at localhost:9000
