from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.permissions import AllowAny
#DjangoObjectPermissions
from rest_framework import generics
from rest_framework.response import Response

from bg_api.serializers import UserSerializer
#from bg_inventory.models import Outlet, Dish

User = get_user_model()


class CreateUser(generics.CreateAPIView, generics.RetrieveAPIView):
    permission_classes = (AllowAny,)
    serializer_class = UserSerializer
    model = User

    def pre_save(self, user):
        user.set_password(user.password)

    def get(self, request, format=None):
        useremail = request.QUERY_PARAMS.get('email', None)
        if useremail:
            try:
                User.objects.get(email=useremail)
                return Response(status=status.HTTP_409_CONFLICT)
            except User.DoesNotExist:
                return Response(status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_404_NOT_FOUND)
