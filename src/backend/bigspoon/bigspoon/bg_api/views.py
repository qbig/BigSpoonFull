from django.contrib.auth import get_user_model
from rest_framework import generics
from rest_framework import status
from rest_framework.authentication import TokenAuthentication, \
    SessionAuthentication
from rest_framework.permissions import AllowAny, DjangoObjectPermissions
from rest_framework.response import Response

from bg_api.serializers import UserSerializer, OutletListSerializer, \
    OutletDetailSerializer
from bg_inventory.models import Outlet

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
                u = User.objects.get(email=useremail)
                return Response({'token': u.auth_token.key})
            except User.DoesNotExist:
                return Response(status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_404_NOT_FOUND)


class ListOutlet(generics.ListAPIView):
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = OutletListSerializer
    model = Outlet


class OutletDetail(generics.RetrieveAPIView):
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = OutletDetailSerializer
    model = Outlet
