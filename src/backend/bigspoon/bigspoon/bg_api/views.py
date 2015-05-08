from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.http import Http404
from django.contrib.auth.models import Group
from django.utils import timezone
from django.db.models import Q

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
    OutletDetailSerializer, ProfileSerializer, MealDetailSerializer,MealAPISerializer, \
    MealSerializer, RequestSerializer, RequestAPISerializer, TokenSerializer, \
    CategorySerializer, NoteSerializer, RatingSerializer, \
    ReviewSerializer, DishSerializer, MealHistorySerializer, \
    SearchDishSerializer, MealSpendingSerializer, SpendingRequestSerializer, \
    FBSerializer, OutletTableSerializer, OrderSerializer, CurrentMealSerializer

from bg_inventory.models import Outlet, Profile, Category, Table, Dish, Note,\
    Rating, Review
from bg_order.models import Meal, Request, Order
from bg_api.tasks import push_to_device, get_printing_task
from utils import send_socketio_message, send_user_feedback, today_limit, five_mins_ago
from bg_api.tasks import send_socketio_message_async, send_user_feedback_async
from decimal import Decimal
# import the logging library
import logging

# Get an instance of a logger
logger = logging.getLogger(__name__)


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
                'avatar_url': u.avatar_url,
                'avatar_url_large': u.avatar_url_large
            })
        return Response({'error':serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


class FBLogin(APIView):
    """
    Get user token by facebook access_token
    """
    throttle_classes = ()
    permission_classes = (AllowAny,)
    parser_classes = (parsers.FormParser, parsers.MultiPartParser,
                      parsers.JSONParser,)
    renderer_classes = (renderers.JSONRenderer,)
    serializer_class = FBSerializer
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
                'avatar_url': u.avatar_url,
                'avatar_url_large': u.avatar_url_large
            })
        return Response({'error':serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


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
    def get_queryset(self):
        return Outlet.objects.filter(is_removed=False)


class OutletDetail(generics.RetrieveAPIView):
    """
    List outlet details including dishes
    """
    permission_classes = (AllowAny,)
    serializer_class = OutletDetailSerializer
    model = Outlet

class OutletItemsView(generics.RetrieveAPIView):
    """
    List current active orders and requests for for current outlet
    """
    permission_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = OutletDetailSerializer
    model = Outlet

    def get(self, request, *args, **kwargs):
        outlet_id = int(kwargs['pk'])
        outlet = Outlet.objects.get(id=outlet_id)
        items_data = {
            "meals": MealAPISerializer(Meal.objects\
                .prefetch_related('diner', 'orders',
                              'table', 'table__outlet')\
                .filter(table__outlet=outlet)\
                .filter(Q(status=Meal.ACTIVE) | Q(status=Meal.ASK_BILL)), many=True).data,

            "requests": RequestAPISerializer(Request.objects\
                .prefetch_related('diner', 'table', 'diner__meals',
                              'diner__meals__orders',
                              'table__outlet')\
                .filter(table__outlet=outlet)\
                .filter(is_active=True), many=True).data
        }
        try:
            return Response(items_data, status=status.HTTP_200_OK)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND)

class NotifyUser(generics.CreateAPIView):
    """
    Modify order quantity for a meal record
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = UserSerializer
    model = User
    def post(self, req, *args, **kwargs):
        try:
            user_id = req.DATA['user_id']
            # send call push API to user with email
            push_to_device.delay("user_id", user_id)
            return Response(status=status.HTTP_201_CREATED)
        except:
            return Response({"error": "Push failed"},
                            status=status.HTTP_400_BAD_REQUEST)

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
        ).all()[:14]

class UpdateOrder(generics.CreateAPIView):
    """
    Modify order quantity for a meal record
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = OrderSerializer
    model = Order
    def post(self, req, *args, **kwargs):
        order_id = int(req.DATA['order_id'])
        new_quant = int(req.DATA['new_quant'])

        try:
            order_to_modify = Order.objects.get(id = int(order_id))
        except Order.DoesNotExist:
            return Response({"error": "Unknown order id " + str(order_id)},
                            status=status.HTTP_400_BAD_REQUEST)
        
        if new_quant == 0:
            order_to_modify.delete()
        else:
            order_to_modify.quantity = new_quant
            order_to_modify.save()

        send_user_feedback(
            "u_%s" % order_to_modify.meal.diner.auth_token.key,
            "Your order of [{dish_name}] has been modified.".format(dish_name=order_to_modify.dish.name)
        )
        return Response({"quantity": new_quant }, status=status.HTTP_201_CREATED)


class UpdateNewOrderForMeal(generics.CreateAPIView):
    """
    Modify a meal record by adding a new dish with quantity 1
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealSerializer
    model = Meal
    def post(self, req, *args, **kwargs):
        table_id = int(req.DATA['from_table'])
        diner_id = int(req.DATA['diner_id'])
        dish_id = int(req.DATA['dish_id'])
        try:
            target_table = Table.objects.get(id=int(table_id))
        except Table.DoesNotExist:
            print "1"
            return Response({"error": "Unknown table id " + str(table_id) + " or " +str(table_id)},
                            status=status.HTTP_400_BAD_REQUEST)
        try:
            current_table_meal = Meal.objects.filter(table=target_table, diner_id=diner_id, is_paid=False).latest('created')
        except Meal.DoesNotExist:
            print "2"
            return Response({"error": "Cannot retrieve current meal for table " + str(table_id)},
                            status=status.HTTP_400_BAD_REQUEST)
        dish = Dish.objects.get(id=int(dish_id))
        try:
            if current_table_meal.status == 0: # ACTIVE
                od = Order.objects.create(meal=current_table_meal, dish=dish, quantity=1)
            else :
                od = Order.objects.create(meal=current_table_meal, dish=dish, quantity=1, is_finished=True)
            send_user_feedback(
                "u_%s" % od.meal.diner.auth_token.key,
                "[{dish_name}] has been added.".format(dish_name=dish.name)
            )
            return Response(OrderSerializer(od).data, status=status.HTTP_201_CREATED)
        except:
            print "3"
            return Response({"error": "Cannot create updating order for " + str(diner_id)},
                            status=status.HTTP_400_BAD_REQUEST)


class UpdateTableForMeal(generics.CreateAPIView):
    """
    Swapping meals record of two tables
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = OutletTableSerializer
    model = Table

    def post(self, req, *args, **kwargs):
        from_table_id = int(req.DATA['from_table'])
        targe_table_id = int(req.DATA['to_table'])
        try:
            target_table = Table.objects.get(id=int(targe_table_id))
            from_table = Table.objects.get(id=int(from_table_id))
        except Table.DoesNotExist:
            return Response({"error": "Unknown table id " + str(from_table_id) + " or " +str(targe_table_id)},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            current_table_meals = list(Meal.objects.filter(table=from_table, is_paid=False))
            try:
                target_table_meals = list(Meal.objects.filter(table=target_table, is_paid=False))                
            except Meal.DoesNotExist:
                logger.error('target table is empty. that\'s ok')
            except:
                logger.error('unexpected error when transfering table')
            for meal in current_table_meals:
                meal.table = target_table
                meal.save()
            for meal in target_table_meals:
                meal.table = from_table
                meal.save()
            
        except Meal.DoesNotExist:
            return Response({"error": "Cannot retrieve current meal for table " + str(from_table_id)},
                            status=status.HTTP_400_BAD_REQUEST)

        return Response("updated", status=status.HTTP_201_CREATED)

class UpdateTableForMealForSingleDiner(generics.CreateAPIView):
    """
    Modify table for a single meal record
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = OutletTableSerializer
    model = Table

    def post(self, req, *args, **kwargs):
        from_table_id = int(req.DATA['from_table'])
        targe_table_id = int(req.DATA['to_table'])
        for_diner = int(req.DATA['diner_id'])
        try:
            target_table = Table.objects.get(id=int(targe_table_id))
            from_table = Table.objects.get(id=int(from_table_id))
        except Table.DoesNotExist:
            return Response({"error": "Unknown table id " + str(from_table_id) + " or " +str(targe_table_id)},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            current_table_meal = Meal.objects.filter(table=from_table, diner_id=for_diner, is_paid=False).latest('created')
            current_table_meal.table = target_table
            current_table_meal.save()
            Request.objects.filter(created__range=today_limit(), diner_id=for_diner, is_active=True).update(table=target_table)
        except Meal.DoesNotExist:
            return Response({"error": "Cannot retrieve current meal for table " + str(from_table_id)},
                            status=status.HTTP_400_BAD_REQUEST)

        return Response("updated", status=status.HTTP_201_CREATED)
       


#NOTE: Use serializer to check and get post data here
class CreateMeal(generics.CreateAPIView, generics.RetrieveAPIView):
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
            return Response({"out_of_stock": "Sorry, we just ran out of stock for "
                             + out_of_stock_str},
                            status=status.HTTP_400_BAD_REQUEST)

        diner = request.user
        #meal, created = Meal.objects.get_or_create(table=table, diner=diner,
        #                                           is_paid=False)
        # Note: here there may exist a discrepency between the table_id sent from user and the table id
        #       from meal, as it could be edited by staff to avoid confusion after diner change their table
        try:
            meal = Meal.objects.filter(created__range=today_limit(), diner=diner, is_paid=False).latest('created')
            table = meal.table
        except Meal.DoesNotExist:
            meal = Meal.objects.create(table=table, diner=diner,
                                                   is_paid=False)
            if table.outlet.is_on_promotion:
                num_of_disconuts_today = Meal.objects.filter(created__range=today_limit(),table__outlet=table.outlet).count()
                if num_of_disconuts_today <= table.outlet.promotion_quota:
                    meal.promotion_note = "${amount} off, customer {count}/{quota}".format(amount=table.outlet.promotion_amount, count=num_of_disconuts_today, quota=table.outlet.promotion_quota)

        meal.modified = timezone.now()

        if table.outlet.is_auto_send_to_POS and not table.is_for_take_away:
            meal.status = Meal.INACTIVE
        else:
            meal.status = Meal.ACTIVE

        if ('note' in request.DATA):
            note = request.DATA['note']
            meal.note = note
        meal.save()

        notes = None
        if ('notes' in request.DATA):
            notes = request.DATA['notes']

        modifiers = None
        if ('modifiers' in request.DATA):
            modifiers = request.DATA['modifiers']

        for idx, dish_pair in enumerate(dishes):
            dish_id = dish_pair.keys()[0]
            dish = Dish.objects.get(id=int(dish_id))
            quantity = dish_pair.values()[0]
            new_order = None
            index_str = str(idx)
            if notes and index_str in notes:
                new_order = Order.objects.create(meal=meal, dish=dish, quantity=quantity, note=notes.get(index_str), is_finished=table.outlet.is_auto_send_to_POS)   
            else:
                new_order = Order.objects.create(meal=meal, dish=dish, quantity=quantity, is_finished=table.outlet.is_auto_send_to_POS)

            if modifiers and index_str in modifiers:
                new_order.modifier_json = modifiers.get(index_str)
                new_order.save()

            # send to printer if configured
            if table.outlet.is_auto_send_to_POS and get_printing_task(table.outlet.id) and not table.is_for_take_away:
                get_printing_task(table.outlet.id).delay(table.id, new_order.id)
            # send done
            dish.quantity -= quantity
            dish.save()
        if not table.outlet.is_auto_send_to_POS:
            push_to_device.delay("outlet_id", str(table.outlet.id))
            send_socketio_message(
                [table.outlet.id],
                ['refresh', 'meal', 'new', str(meal.id)]
            )
        return Response({"meal": meal.id, }, status=status.HTTP_201_CREATED)

    def get(self, request):
        diner = request.user
        is_checking_new = request.QUERY_PARAMS.get('new', None)
        try:
            meal = Meal.objects.filter(modified__range=five_mins_ago(), diner=diner, is_paid=False).latest('modified')
            if is_checking_new and not meal.table.outlet.is_auto_send_to_POS:
                data = MealAPISerializer(meal).data  # finish=False
            else:
                data = MealSerializer(meal).data
            return Response(data, status=status.HTTP_200_OK)
        except Meal.DoesNotExist:
            return Response({"error": "Not found"}, status=status.HTTP_404_NOT_FOUND)


class ProcessMealForPOS(generics.CreateAPIView, generics.ListAPIView):
    """
    Create new meal
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = CurrentMealSerializer
    model = Meal

    def post(self, request, *args, **kwargs):
        order_ids = request.DATA['order_ids']
        try:
            for o_id in order_ids:
                order = Order.objects.get(id=int(o_id))
                order.is_finished = True
                order.has_been_sent_to_POS = True
                order.meal.status = 1
                order.meal.save()
                order.save()

        except Order.DoesNotExist:
            return Response({"error": "Unknown order id " + str(o_id)},
                            status=status.HTTP_400_BAD_REQUEST)

        outlet_id = self.request.QUERY_PARAMS.get('outlet_id', None)
        send_socketio_message(
            [outlet_id],
            ['refresh', 'meal', 'new']
        )
        return Response({"success": 1, }, status=status.HTTP_201_CREATED)

    def get_queryset(self):
        outlet_id = self.request.QUERY_PARAMS.get('outlet_id', None)
        outlet = Outlet.objects.get(id=int(outlet_id))

        return Meal.objects.filter(
            table__outlet=outlet,
            is_paid=False
        )


class MealDetail(generics.RetrieveAPIView):
    """
    Show meal details
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealDetailSerializer
    model = Meal


class MealDetailAPIView(generics.RetrieveAPIView):
    """
    Show meal details for dashboard
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealAPISerializer
    model = Meal

class RequestDetailAPIView(generics.RetrieveAPIView):
    """
    Show request details
    """
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = RequestAPISerializer
    model = Request

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
        try:
            meal = Meal.objects.filter(created__range=today_limit(), diner=self.request.user, is_paid=False).latest('modified')
            obj.table = meal.table
        except Meal.DoesNotExist:
            Meal.objects.create(table=obj.table, diner=obj.diner, modified=timezone.now(),
                                                   is_paid=False, status=Meal.INACTIVE)

    def post_save(self, obj, created=False):
        push_to_device.delay("outlet_id", str(obj.table.outlet.id))
        send_socketio_message(
            [obj.table.outlet.id],
            ['refresh', 'request', 'new', str(obj.id)]
        )


#NOTE: Use serializer to check and get post data here
class AskForBill(generics.GenericAPIView):
    authentication_classes = (SessionAuthentication, TokenAuthentication)
    permission_classes = (DjangoObjectPermissions,)
    serializer_class = MealDetailSerializer
    model = Meal

    def post(self, request, *args, **kwargs):
        table = get_object_or_404(Table, id=int(request.DATA['table']))
        diner = request.user
        meals = Meal.objects.filter(diner=diner,
                                    is_paid=False).order_by('-modified')
        if meals.count() >= 1:
            meal = meals[0]
            meal.modified = timezone.now()
            if meal.table.outlet.is_auto_send_to_POS:
                meal.is_paid = True
            else:
                meal.status = Meal.ASK_BILL
                push_to_device.delay("outlet_id", str(table.outlet.id))
                send_socketio_message_async.delay(
                    "||".join([str(table.outlet.id)]),
                    "||".join(['refresh', 'meal', 'askbill', str(meal.id)])
                )
            meal.save()

            return Response({"meal": meal.id, }, status=status.HTTP_200_OK)

        return Response({"error": "No unpaid meal for this user", },
                        status=status.HTTP_400_BAD_REQUEST)


#NOTE: Use serializer to check and get post data here
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
                [str(rating.dish.outlet.id)],
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


class SearchOutletByDish(generics.GenericAPIView):
    model = Outlet
    serializer_class = SearchDishSerializer

    def post(self, req, *args, **kwargs):
        serializer = self.get_serializer(
            data=req.DATA,
            files=req.FILES
        )
        if serializer.is_valid():
            outlets = Outlet.objects.filter(
                Q(dishes__name__icontains=serializer.data['name']) |
                Q(dishes__desc__icontains=serializer.data['name'])
            ).values_list("id", "name").distinct()
            if outlets.count() > 0:
                return Response([
                    {"id": o[0], "name": o[1]} for o in outlets
                ], status=status.HTTP_200_OK)
            return Response("no results",
                            status=status.HTTP_404_NOT_FOUND)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


#NOTE: Use serializer to check and get post data here
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
        send_user_feedback(
                "u_%s" % meal.diner.auth_token.key,
                'Your bill has been closed by waiter.'
            )
        send_socketio_message(
                request.user.outlet_ids,
                ['refresh', 'meal', 'closebill', str(meal.id)]
            )
        return Response(MealDetailSerializer(meal).data,
                        status=status.HTTP_200_OK)


class ClearBill(generics.GenericAPIView):
    """
        Discontinue session, for phone on the table usage
    """
    authentication_classes = (TokenAuthentication,)
    model = Meal

    def post(self, request, *args, **kwargs):
        try:
            table_id = request.DATA['table']
            table = Table.objects.get(id=int(table_id))
        except Table.DoesNotExist:
            return Response({"error": "Unknown table id " + str(table_id)},
                            status=status.HTTP_400_BAD_REQUEST)

        for meal in table.meals.filter(is_paid=False):
            meal.status = Meal.INACTIVE
            meal.is_paid = True
            meal.bill_time = timezone.now()
            meal.save()
        return Response({"success": True},
                        status=status.HTTP_200_OK)
#NOTE: Use serializer to check and get post data here
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
        if meal.table.outlet.is_on_promotion and meal.promotion_note and meal.orders.filter(is_finished=True).count() == 0:
            feedback_msg = 'Lucky you!\nEarly bird catches the worm,\nhere is ${amount} off your final receipt!'.format(amount=meal.table.outlet.promotion_amount)
        else:
            feedback_msg = 'Your order has been processed.'

        for order in meal.orders.all():
            if meal.table.outlet.is_auto_send_to_POS and meal.table.is_for_take_away:
                get_printing_task(meal.table.outlet.id).delay(meal.table.id, order.id, print_bool=True)

            # if not integrated, alway set as true
            # if integrated, and finished(default state), do not touch
            # if integrated, and not finished(printing failed), set it as printed(waiter manually)
            if not meal.table.is_for_take_away and \
              (not meal.table.outlet.is_auto_send_to_POS or not order.is_finished):
                order.has_been_sent_to_POS = True
            order.is_finished = True
            order.save()
        meal.save()
        send_socketio_message(
            request.user.outlet_ids,
            ['refresh', 'meal', 'ack', str(meal.id)]
        )

        send_user_feedback(
            "u_%s" % meal.diner.auth_token.key,
            feedback_msg
        )
        return Response(MealDetailSerializer(meal).data,
                        status=status.HTTP_200_OK)


#NOTE: Use serializer to check and get post data here
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
            ['refresh', 'request', 'ack', str(req.id)]
        )

        if (req.request_type == Request.WATER):
            send_user_feedback(
                "u_%s" % req.diner.auth_token.key,
                'Water you requested is coming soon.'
            )
        else:
            send_user_feedback(
                "u_%s" % req.diner.auth_token.key,
                'Waiter will come to your table soon.'
            )
        return Response(RequestSerializer(req).data,
                        status=status.HTTP_200_OK)

#NOTE: Use serializer to check and get post data here
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


#NOTE: Use serializer to check and get post data here
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
        dish.is_active = bool(int(req.DATA['is_active']))
        dish.save()
        return Response(DishSerializer(dish).data,
                        status=status.HTTP_200_OK)


#NOTE: Use serializer to check and get post data here
class GetSpendingData(generics.GenericAPIView):
    serializer_class = SpendingRequestSerializer
    authentication_classes = (SessionAuthentication,)
    permission_classes = (IsAuthenticated,)
    model = Meal

    def post(self, req, *args, **kwargs):
        serializer = self.get_serializer(
            data=req.DATA,
            files=req.FILES
        )
        if serializer.is_valid():
            meals_past_week = Meal.objects.filter(
                table__outlet__in=req.user.outlet_ids,
                created__gte=serializer.data['from_date'],
                created__lte=serializer.data['to_date'])
            return Response(
                MealSpendingSerializer(meals_past_week, many=True).data,
                status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
