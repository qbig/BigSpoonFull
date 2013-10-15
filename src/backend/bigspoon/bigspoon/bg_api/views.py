from rest_framework import viewsets
from rest_framework.permissions import DjangoObjectPermissions

from bg_api.serializers import DishSerializer
from bg_inventory.models import Dish


class DishViewSet(viewsets.ModelViewSet):
    """
    Dish API
    """
    queryset = Dish.objects.all()
    serializer_class = DishSerializer
    permission_classes = (DjangoObjectPermissions,)
