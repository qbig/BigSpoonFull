from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.http import Http404
from django.contrib.auth.models import Group
from django.utils import timezone

from rest_framework import generics
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.authentication import TokenAuthentication, \
    SessionAuthentication
from rest_framework.permissions import AllowAny, DjangoObjectPermissions, \
    IsAuthenticated
from rest_framework.response import Response
from rest_framework import parsers
from rest_framework import renderers
from rest_framework.authtoken.models import Token

from bg_api.serializers import UserSerializer, OutletListSerializer, \
    OutletDetailSerializer, ProfileSerializer, MealDetailSerializer, \
    MealSerializer, RequestSerializer, TokenSerializer, \
    CategorySerializer, NoteSerializer, RatingSerializer, \
    ReviewSerializer, DishSerializer, MealHistorySerializer

from bg_inventory.models import Outlet, Profile, Category, Table, Dish, Note,\
    Rating, Review
from bg_order.models import Meal, Request, Order
from utils import send_socketio_message

from decimal import Decimal

User = get_user_model()


class CreateUser(generics.CreateAPIView, generics.RetrieveAPIView):
    """
    Create User or Check user email exists
    """
    permission_classes = (AllowAny,)
    serializer_class = UserSerializer
    model = User

    def pre_save(self, obj):
        obj.set_password(obj.password)
        obj.is_active = True

    def post_save(self, obj, created=False):
        # add to normal user group
        g = Group.objects.get(name='normaluser')
        g.user_set.add(obj)
        g.save()

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
                'auth_token': token.key,
                'avatar_url': u.avatar_url
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


class MealHistory(generics.ListAPIView):
    """
    List all meals belong to person
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealHistorySerializer
    model = Meal

    def get_queryset(self):
        return Meal.objects.filter(
            diner=self.request.user,
            is_paid=True
        )


class CreateMeal(generics.CreateAPIView):
    """
    Create new meal
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealSerializer
    model = Meal

    def post(self, request, *args, **kwargs):
        dishes = request.DATA['dishes']
        table_id = request.DATA['table']
        try:
            table = Table.objects.get(id=int(table_id))
        except Table.DoesNotExist:
            return Response({"error": "Unknown table id " + str(table_id)},
                            status=status.HTTP_400_BAD_REQUEST)

        # Check quantity
        out_of_stock = []
        for dish_pair in dishes:
            dish_id = dish_pair.keys()[0]
            try:
                dish = Dish.objects.get(id=int(dish_id))
            except Dish.DoesNotExist:
                return Response({"error": "Unknown dish id " + str(dish_id)},
                                status=status.HTTP_400_BAD_REQUEST)
            quantity = dish_pair.values()[0]
            stock_quantity = dish.quantity

            if stock_quantity < quantity:
                out_of_stock.append(dish.name)

        if(len(out_of_stock) > 0):
            #returns "" if there's only 1 element.
            out_of_stock_str = ", ".join(out_of_stock[:-1])
            if (len(out_of_stock) > 1):
                out_of_stock_str += " and "
            out_of_stock_str += out_of_stock[-1]
            return Response({"error": "Sorry, we ran out of stock for "
                             + out_of_stock_str},
                            status=status.HTTP_400_BAD_REQUEST)

        diner = request.user
        meal, created = Meal.objects.get_or_create(table=table, diner=diner,
                                                   is_paid=False)
        meal.modified = timezone.now()
        meal.status = Meal.ACTIVE
        if ('note' in request.DATA):
            note = request.DATA['note']
            meal.note += "\r\n" + note
        meal.save()

        for dish_pair in dishes:
            dish = Dish.objects.get(id=int(dish_pair.keys()[0]))
            quantity = dish_pair.values()[0]
            Order.objects.create(meal=meal, dish=dish, quantity=quantity)
            dish.quantity -= quantity
            dish.save()

        send_socketio_message(
            [table.outlet.id],
            ['refresh', 'meal', 'new']
        )
        return Response({"meal": meal.id, }, status=status.HTTP_201_CREATED)


class MealDetail(generics.RetrieveAPIView):
    """
    Show meal details
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealDetailSerializer
    model = Meal


class CreateRequest(generics.CreateAPIView):
    """
    Create new request
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = RequestSerializer
    model = Request

    def pre_save(self, obj):
        obj.diner = self.request.user

    def post_save(self, obj, created=False):
        send_socketio_message(
            [obj.table.outlet.id],
            ['refresh', 'request', 'new']
        )


class AskForBill(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealDetailSerializer
    model = Meal

    def post(self, request, *args, **kwargs):
        table = get_object_or_404(Table, id=int(request.DATA['table']))
        diner = request.user
        meals = Meal.objects.filter(table=table, diner=diner,
                                    is_paid=False)
        if meals.count() == 1:
            meal = meals[0]
            meal.status = Meal.ASK_BILL
            meal.modified = timezone.now()
            meal.save()
            send_socketio_message(
                [table.outlet.id],
                ['refresh', 'meal', 'askbill']
            )
            return Response({"meal": meal.id, }, status=status.HTTP_200_OK)

        return Response({"error": "No unpaid meal for this user", },
                        status=status.HTTP_400_BAD_REQUEST)


class CreateRating(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = RatingSerializer
    model = Rating

    def post(self, request, *args, **kwargs):
        diner = request.user
        dishes = request.DATA['dishes']
        for dish_pair in dishes:
            dish_id = dish_pair.keys()[0]
            try:
                dish = Dish.objects.get(id=int(dish_id))
            except Dish.DoesNotExist:
                return Response({"error": "Unknown dish id " + str(dish_id)},
                                status=status.HTTP_400_BAD_REQUEST)
            rating, created = Rating.objects.get_or_create(
                user=diner,
                dish=dish,
            )
            rating.score = Decimal(str(dish_pair.values()[0]))
            rating.save()
        send_socketio_message(
            [rating.dish.outlet.id],
            ['refresh', 'rating']
        )
        return Response("ratings created", status=status.HTTP_200_OK)


class CreateReview(generics.CreateAPIView):
    """
    Create or change review
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = ReviewSerializer
    model = Review

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(
            data=request.DATA,
            files=request.FILES
        )

        if serializer.is_valid():
            review, created = Review.objects.get_or_create(
                user=request.user,
                outlet_id=int(serializer.data['outlet']),
            )
            review.feedback = serializer.data['feedback']
            review.save()
            serializer.data['user'] = review.user.id
            headers = self.get_success_headers(serializer.data)
            send_socketio_message(
                [review.outlet.id],
                ['refresh', 'review']
            )
            return Response(serializer.data, status=status.HTTP_201_CREATED,
                            headers=headers)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# internal API for staff app only
class CloseBill(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (DjangoObjectPermissions,)
    model = Meal

    def post(self, request, *args, **kwargs):
        try:
            meal = Meal.objects.get(pk=int(request.DATA['meal']))
        except Meal.DoesNotExist:
            raise Http404
        if not request.user.has_perm('change_meal', meal):
            return Response({
                "details": "You do not have permission to perform this action."
            }, status=status.HTTP_403_FORBIDDEN)
        meal.status = Meal.INACTIVE
        meal.is_paid = True
        meal.bill_time = timezone.now()
        meal.save()
        send_socketio_message(
            request.user.outlet_ids,
            ['refresh', 'meal', 'closebill']
        )
        return Response(MealDetailSerializer(meal).data,
                        status=status.HTTP_200_OK)


class AckOrder(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (DjangoObjectPermissions,)
    model = Meal

    def post(self, request, *args, **kwargs):
        try:
            meal = Meal.objects.get(pk=int(request.DATA['meal']))
        except Meal.DoesNotExist:
            raise Http404
        if not request.user.has_perm('change_meal', meal):
            return Response({
                "details": "You do not have permission to perform this action."
            }, status=status.HTTP_403_FORBIDDEN)
        meal.status = Meal.INACTIVE
        meal.modified = timezone.now()
        meal.save()
        send_socketio_message(
            request.user.outlet_ids,
            ['refresh', 'meal', 'ack']
        )
        return Response(MealDetailSerializer(meal).data,
                        status=status.HTTP_200_OK)


class AckRequest(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (DjangoObjectPermissions,)
    model = Request

    def post(self, request, *args, **kwargs):
        try:
            req = Request.objects.get(pk=int(request.DATA['request']))
        except Meal.DoesNotExist:
            raise Http404
        if not request.user.has_perm('change_request', req):
            return Response({
                "details": "You do not have permission to perform this action."
            }, status=status.HTTP_403_FORBIDDEN)
        req.is_active = False
        req.finished = timezone.now()
        req.save()
        send_socketio_message(
            request.user.outlet_ids,
            ['refresh', 'request', 'ack']
        )
        return Response(RequestSerializer(req).data,
                        status=status.HTTP_200_OK)


class CreateNote(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (IsAuthenticated,)
    model = Note

    def post(self, req, *args, **kwargs):
        try:
            note = Note.objects.get_or_create(user_id=int(req.DATA['user']),
                                              outlet_id=int(req.DATA['outlet'])
                                              )[0]
        except Note.DoesNotExist:
            raise Http404
        note.content = req.DATA['content']
        note.save()
        return Response(NoteSerializer(note).data,
                        status=status.HTTP_200_OK)


class UpdateDish(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (IsAuthenticated,)
    model = Dish

    def post(self, req, *args, **kwargs):
        id = int(kwargs['pk'])
        try:
            dish = Dish.objects.get(id=id)
        except Dish.DoesNotExist:
            raise Http404
        dish.name = req.DATA['name']
        dish.price = Decimal(str(req.DATA['price']))
        dish.pos = req.DATA['pos']
        dish.desc = req.DATA['desc']
        dish.start_time = req.DATA['start_time']
        dish.end_time = req.DATA['end_time']
        dish.quantity = int(req.DATA['quantity'])
        dish.save()
        return Response(DishSerializer(dish).data,
                        status=status.HTTP_200_OK)
