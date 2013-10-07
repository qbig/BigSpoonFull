BigSpoon Django Backend setup instructions
------

### ssh config

```
Host 3216-final
    HostName 122.248.199.242
    User ec2-user
    IdentityFile ~/.ssh/bigspoon.pem
```

### server environment variables

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

1. Install [`virtualenv`](http://www.virtualenv.org/en/latest/#installation) for python
2. `virtualenv env` (make sure you are at the same folder where this README file is in)
3. `source env/bin/activate`
4. `pip install -r bigspoon/reqs/dev.txt`
