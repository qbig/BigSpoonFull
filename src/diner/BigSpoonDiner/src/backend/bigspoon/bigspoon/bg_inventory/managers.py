from django.utils import timezone
from django.contrib.auth.models import BaseUserManager


class UserManager(BaseUserManager):
    """
    email and password are required.
    """

    def get_user_unsaved(self, email, password, **extra_fields):
        if not email:
            raise ValueError('Email is required.')
        now = timezone.now()
        email = self.normalize_email(email)
        user = self.model(email=email, is_staff=False,
                          is_active=False, is_superuser=False,
                          last_login=now, date_joined=now, **extra_fields)

        user.set_password(password)
        return user

    def create_user(self, email, password=None, **extra_fields):
        """
        Creates and saves a User with the given email and password.
        """
        u = self.get_user_unsaved(email, password, **extra_fields)
        u.save(using=self._db)
        return u

    def create_superuser(self, email, password, **extra_fields):
        """
        Creates and saves a Super User with the given email and password.
        """
        u = self.get_user_unsaved(email, password, **extra_fields)
        u.is_staff = True
        u.is_active = True
        u.is_superuser = True
        u.save(using=self._db)
        return u
