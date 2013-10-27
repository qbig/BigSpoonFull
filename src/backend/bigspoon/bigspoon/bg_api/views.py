from django.contrib.auth import get_user_model
from django.http import Http404

from rest_framework import generics
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.authentication import TokenAuthentication, \
    SessionAuthentication
from rest_framework.permissions import AllowAny, DjangoObjectPermissions
from rest_framework.response import Response
from rest_framework import parsers
from rest_framework import renderers
from rest_framework.authtoken.models import Token

from bg_api.serializers import UserSerializer, OutletListSerializer, \
    OutletDetailSerializer, ProfileSerializer, MealDetailSerializer, \
    MealSerializer, RequestSerializer, TokenSerializer, \
    CategorySerializer
from bg_inventory.models import Outlet, Profile, Category, Table, Dish
from bg_order.models import Meal, Request, Order

User = get_user_model()


class CreateUser(generics.CreateAPIView, generics.RetrieveAPIView):
    """
    Create User or Check user email exists
    """
    permission_classes = (AllowAny,)
    serializer_class = UserSerializer
    model = User

    def pre_save(self, user):
        user.set_password(user.password)

    def get(self, request):
        useremail = request.QUERY_PARAMS.get('email', None)
        if useremail:
            try:
                User.objects.get(email=useremail)
                return Response(status=status.HTTP_409_CONFLICT)
            except User.DoesNotExist:
                return Response(status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_404_NOT_FOUND)

    def post(self, request, *args, **kwargs):
        response = self.create(request, *args, **kwargs)
        if 'password' in response.data.keys():
            del response.data['password']
        return response


class LoginUser(APIView):
    """
    Get user token by email and password
    """
    throttle_classes = ()
    permission_classes = (AllowAny,)
    parser_classes = (parsers.FormParser, parsers.MultiPartParser,
                      parsers.JSONParser,)
    renderer_classes = (renderers.JSONRenderer,)
    serializer_class = TokenSerializer
    model = Token

    def post(self, request):
        serializer = self.serializer_class(data=request.DATA)
        if serializer.is_valid():
            u = serializer.object['user']
            token, created = Token.objects.get_or_create(
                user=u
            )
            return Response({
                'email': u.email,
                'first_name': u.first_name,
                'last_name': u.last_name,
                'auth_token': token.key
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserProfile(generics.RetrieveAPIView, generics.UpdateAPIView):
    """
    Get or update user profile
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = ProfileSerializer
    model = Profile

    def get_object(self):
        try:
            profile = self.request.user.profile
            return profile
        except Profile.DoesNotExist:
            raise Http404


class ListOutlet(generics.ListAPIView):
    """
    List all outlets
    """
    permission_classes = (AllowAny,)
    serializer_class = OutletListSerializer
    model = Outlet


class OutletDetail(generics.RetrieveAPIView):
    """
    List outlet details including dishes
    """
    permission_classes = (AllowAny,)
    serializer_class = OutletDetailSerializer
    model = Outlet


class ListCategory(generics.ListAPIView):
    """
    List all categories
    """
    permission_classes = (AllowAny,)
    serializer_class = CategorySerializer
    model = Category


class CreateMeal(generics.CreateAPIView):
    """
    Create new meal
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    model = Meal
    serializer_class = MealSerializer

    def post(self, request, *args, **kwargs):
        dishes = request.DATA['dishes']

        # Check quantity
        for dish_pair in dishes:
            dish = Dish.objects.get(id=int(dish_pair.keys()[0]))
            quantity = dish_pair.values()[0]
            stock_quantity = dish.quantity

            if stock_quantity < quantity:
                return Response({"error": "Not enough stock for dish ID "
                                + str(dish.id)},
                                status=status.HTTP_400_BAD_REQUEST)

        table = Table.objects.get(id=request.DATA['table'])
        diner = request.user
        meal, created = Meal.objects.get_or_create(table=table, diner=diner,
                                                   is_paid=False)

        for dish_pair in dishes:
            dish = Dish.objects.get(id=int(dish_pair.keys()[0]))
            quantity = dish_pair.values()[0]
            Order.objects.create(meal=meal, dish=dish, quantity=quantity)
            dish.quantity -= quantity
            dish.save()

        return Response({"meal_id": meal.id, }, status=status.HTTP_201_CREATED)


class MealDetail(generics.RetrieveAPIView):
    """
    Show meal details
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealDetailSerializer
    model = Meal


class CreateRequest(generics.ListCreateAPIView):
    """
    Create new request
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    queryset = Request.objects.all()
    serializer_class = RequestSerializer


class AskForBillView(generics.GenericAPIView):
    pass
