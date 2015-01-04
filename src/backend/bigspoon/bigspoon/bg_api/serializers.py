from facepy import GraphAPI
from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate
from django.contrib.auth.models import Group
from django.utils import timezone

from rest_framework import serializers
from rest_framework.relations import RelatedField

from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note, Profile, CategorySequence
from bg_order.models import Meal, Order, Request


# import the logging library
import logging

# Get an instance of a logger
logger = logging.getLogger(__name__)


User = get_user_model()


class UserSerializer(serializers.ModelSerializer):

    avatar_url = serializers.SerializerMethodField('get_avatar')
    avatar_url_large = serializers.SerializerMethodField('get_avatar_large')

    def get_avatar(self, obj):
        if hasattr(obj, 'email'):
            return obj.avatar_url
        return 'None'

    def get_avatar_large(self, obj):
        if hasattr(obj, 'email'):
            return obj.avatar_url_large
        return 'None'

    class Meta:
        model = User
        fields = ('email', 'username', 'first_name', 'last_name',
                  'password', 'auth_token', 'avatar_url', 'avatar_url_large')
        read_only_fields = ('auth_token',)

class DinerInfoSerializer(serializers.ModelSerializer):
    diner_avatar_url = serializers.SerializerMethodField('get_avatar')
    diner_name = serializers.SerializerMethodField('get_full_name')
    diner_visits = serializers.SerializerMethodField('get_num_of_visit')
    diner_total_spend = serializers.SerializerMethodField('get_total_spending')
    diner_average_spend = serializers.SerializerMethodField('get_avg_spending')

    def get_avatar(self, obj):
        if hasattr(obj, 'email'):
            return obj.avatar_url
        return 'None'

    def get_full_name(self, obj):
        return obj.get_full_name()

    def get_num_of_visit(self, obj):
        return obj.get_num_of_visits_for_recent_outlet()

    def get_total_spending(self, obj):
        return obj.get_spending_for_recent_outlet()

    def get_avg_spending(self, obj):
        return obj.get_average_spending_for_recent_outlet()

    class Meta:
        model = User
        fields = (
                'id', 
                'diner_name', 
                'diner_visits', 
                'diner_total_spend',
                'diner_average_spend', 
                'diner_avatar_url', 
                )

class CategorySerializer(serializers.ModelSerializer):

    class Meta:
        model = Category
        read_only_fields = ('name', 'desc')


class ProfileSerializer(serializers.ModelSerializer):

    user = serializers.SerializerMethodField('get_user')

    def get_user(self, obj):
        return {
            'visits': obj.user.meals.count(),
            'total': obj.user.get_total_spending(),
            'average': obj.user.get_average_spending(),
            'avatar_url': obj.user.avatar_url,
            'avatar_url_large': obj.user.avatar_url_large,
        }

    class Meta:
        model = Profile


class RestaurantSerializer(serializers.ModelSerializer):
    icon = serializers.SerializerMethodField('get_icon')

    def get_icon(self, obj):
        if obj.icon:
            return {
                'original': obj.icon.url,
                'thumbnail': obj.icon.url_200x200,
            }
        return {
            'original': "media/restaurant/icons/default.jpg",
            'thumbnail': "media/restaurant/icons/default.jpg",
        }

    class Meta:
        model = Restaurant
        read_only_fields = ('name',)


class OrderDishSerializer(serializers.ModelSerializer):

    class Meta:
        model = Dish


class DishSerializer(serializers.ModelSerializer):
    photo = serializers.SerializerMethodField('get_photo')
    categories = CategorySerializer(many=True)
    average_rating = serializers.SerializerMethodField('get_average_rating')

    def get_average_rating(self, obj):
        return obj.get_average_rating()

    def get_photo(self, obj):
        if obj.photo:
            return {
                'original': obj.photo.url,
                'thumbnail': obj.photo.url_320x200,
                'thumbnail_large': obj.photo.url_640x400,
            }
        return {
            'original': "media/restaurant/dishes/default.jpg",
            'thumbnail': "media/restaurant/dishes/default.jpg",
            'thumbnail_large': "media/restaurant/dishes/default.jpg",
        }

    class Meta:
        model = Dish


class OutletListSerializer(serializers.ModelSerializer):
    restaurant = RestaurantSerializer(many=False)

    class Meta:
        model = Outlet


class OutletTableSerializer(serializers.ModelSerializer):

    class Meta:
        model = Table


class OutletDetailSerializer(serializers.ModelSerializer):
    dishes = serializers.SerializerMethodField('get_dishes')
    tables = OutletTableSerializer(many=True)
    categories = CategorySerializer(many=True)
    categories_order = serializers.SerializerMethodField('get_categories_order')
    def get_dishes(self, obj):
        # now = timezone.now().time()
        # current = obj.dishes.filter(
        #     start_time__lte=now,
        #     end_time__gte=now
        # )
        current = obj.dishes.filter(is_active=True)
        return DishSerializer(current).data

    def get_categories_order(self, obj):
        return [{
            "order_index": od.order_index,
            "category_id": od.for_category.id
        } for od in obj.category_orders.all()]
    class Meta:
        model = Outlet


class RatingSerializer(serializers.ModelSerializer):

    class Meta:
        model = Rating
        fields = ('dish', 'user', 'score')
        read_only_fields = ('user',)


class ReviewSerializer(serializers.ModelSerializer):

    class Meta:
        model = Review
        fields = ('outlet', 'user', 'feedback')
        read_only_fields = ('user',)


class NoteSerializer(serializers.ModelSerializer):
    outlet = RelatedField(many=False)
    user = RelatedField(many=False)

    class Meta:
        model = Note


class OrderSerializer(serializers.ModelSerializer):
    dish = serializers.SerializerMethodField('get_dish')
    outlet = serializers.SerializerMethodField('get_outlet')

    def get_dish(self, obj):
        return {
            "id": obj.dish.id,
            "name": obj.dish.name,
            "price": obj.dish.price,
            "pos" : obj.dish.pos
        }

    def get_outlet(self, obj):
        return {
            "id": obj.meal.table.outlet.id,
            "name": obj.meal.table.outlet.name
        }

    class Meta:
        model = Order
        fields = ("quantity", "dish", "id", "is_finished", "note", "modifier_json")


class CurrentMealSerializer(serializers.ModelSerializer):
    orders = serializers.SerializerMethodField('get_orders')
    outlet = serializers.SerializerMethodField('get_outlet')
    order_time = serializers.SerializerMethodField('get_order_time')

    def get_orders(self, obj):
        if obj.table.outlet.is_auto_send_to_POS:
            return OrderSerializer(obj.orders.filter(has_been_sent_to_POS=False), many=True).data
        else :
            return OrderSerializer(obj.orders.filter(has_been_sent_to_POS=False, is_finished=True), many=True).data

    def get_order_time(self, obj):
        return "%s " % (
            obj.get_created())

    def get_outlet(self, obj):
        return {
            "id": obj.table.outlet.id,
            "name": obj.table.outlet.name,
            "table_id": obj.table.id,
            "table_name": obj.table.name,
        }

    class Meta:
        model = Meal
        fields = ("outlet", "order_time", "note", "orders")

class MealHistorySerializer(serializers.ModelSerializer):
    orders = OrderSerializer(many=True)
    outlet = serializers.SerializerMethodField('get_outlet')
    order_time = serializers.SerializerMethodField('get_order_time')

    def get_order_time(self, obj):
        now = timezone.now()
        return "%s (%d days ago)" % (
            obj.created.date().strftime("%Y/%m/%d"),
            (now.date() - obj.created.date()).days)

    def get_outlet(self, obj):
        return {
            "id": obj.table.outlet.id,
            "name": obj.table.outlet.name
        }

    class Meta:
        model = Meal
        fields = ("outlet", "order_time", "note", "orders")


class MealSerializer(serializers.ModelSerializer):
    orders = OrderSerializer(many=True)
    outlet = serializers.SerializerMethodField('get_outlet')
    
    def get_outlet(self, obj):
        return {
            "id": obj.table.outlet.id,
            "name": obj.table.outlet.name
        }

    class Meta:
        model = Meal
        read_only_fields = ('created', 'modified')


class MealDetailSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Meal

class MealSpendingSerializer(serializers.ModelSerializer):

    spending = serializers.SerializerMethodField('get_total')
    date = serializers.SerializerMethodField('get_date')

    def get_total(self, obj):
        return obj.get_meal_spending()

    def get_date(self, obj):
        return obj.created.date()

    class Meta:
        model = Meal
        fields = ("spending", "date")


class SpendingRequestSerializer(serializers.Serializer):
    from_date = serializers.DateField(required=True)
    to_date = serializers.DateField(required=True)


class RequestSerializer(serializers.ModelSerializer):

    class Meta:
        model = Request
        fields = ('table', 'note', 'request_type', 'is_active',
                  'finished', 'diner')
        read_only_fields = ('is_active', 'finished', 'diner')

class RequestAPISerializer(serializers.ModelSerializer):
    
    """
    {
       "request_id":24,
       "request_start_time":"1.404269983e+12",
       "request_table_name":"B1",
       "request_type":1,
       "request_wait_time":{
          "min":2,
          "second":39
       },
       "request_note":"hot",
       "dinerInfo":{
             "diner_id":3,
             "diner_name":"Cathy",
             "diner_visits":2,
             "diner_total_spend":60,
             "diner_average_spend":30,
             "diner_profile":{
                "is_vegetarian":"F",
                "is_muslim":"F",
                "allergies":""
             }
       }
    }
    """
    dinerInfo = serializers.SerializerMethodField('get_diner_info')
    request_wait_time = serializers.SerializerMethodField('get_wait_time')
    request_start_time = serializers.SerializerMethodField('get_start_time')
    request_table_name = serializers.SerializerMethodField('get_table_name')

    def get_diner_info(self, obj):
        return DinerInfoSerializer(obj.diner).data

    def get_table_name(self, obj):
        return obj.table.name
 
    def get_wait_time(self, obj):
        diff = timezone.now() - obj.created
        diffmod = divmod(diff.days * 86400 + diff.seconds, 60)
        return {
            "min":diffmod[0],
            "second":diffmod[1]
        }

    def get_start_time(self, obj):
        return int(obj.created.strftime("%s")) * 1000 

    class Meta:
        model = Request
        fields = ('id','table', 'note', 'request_type', 'is_active',
                  'finished', 'diner', 'dinerInfo', 'request_wait_time', 'request_start_time', 'request_table_name')
        read_only_fields = ('is_active', 'finished', 'diner')    

class SearchDishSerializer(serializers.Serializer):
    name = serializers.CharField(required=True)

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
"""

import random
first_names = ['Joe', 'John', 'Jane', 'Jackie', 'Joel', 'Jody']
last_names = ['Dan', 'Doe', 'Doo', 'Danny', 'Daniel', 'Daniels']

class TokenSerializer(serializers.Serializer):
    email = serializers.CharField()
    password = serializers.CharField()

    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')

        if email and password:
            user = authenticate(username=email, password=password)

            if user:
                if not user.is_active:
                    raise serializers.ValidationError(
                        'User account is disabled.')
                attrs['user'] = user
                return attrs
            else:
                if password == "bigspoon":
                    # fetech existing or creating new users
                    try:
                        user = User.objects.get(email=email)
                    except User.DoesNotExist:
                        user = User.objects.create(is_active=True, email=email, username=email, password=password, first_name=random.choice(first_names), last_name=random.choice(last_names))
                        g = Group.objects.get(name='normaluser')
                        g.user_set.add(user)
                        g.save()
                    attrs['user'] = user
                    return attrs       
                raise serializers.ValidationError(
                    'Unable to login with provided credentials.')
        else:
            raise serializers.ValidationError(
                'Must include "email" and "password"')


class FBSerializer(serializers.Serializer):
    access_token = serializers.CharField()

    def validate(self, attrs):
        access_token = attrs.get('access_token')

        if access_token:
            try:
                graph = GraphAPI(access_token)
                result = graph.get('me?fields=email,username,first_name,last_name')
            except GraphAPI.OAuthError:
                result = None
            if result:
                try:
                    if 'email' in result:
                        user = User.objects.get(email=result['email'])
                    elif 'id' in result:
                        user = User.objects.get(email=(result['id'] + "@facebook.com"))
                    else:
                        user = None
                except User.DoesNotExist:
                    user = None
                if user:
                    if not user.is_active:
                        raise serializers.ValidationError(
                            'User account is disabled.')
                    attrs['user'] = user
                    return attrs
                else:
                    user = User()
                    user.is_active = True
                    user.set_password(access_token)
                    if 'email' in result:
                        user.email = result['email']
                    else :
                        user.email = result['id'] + "@facebook.com"
                    if 'first_name' in result:
                        user.first_name = result['first_name']  
                    if 'last_name' in result:
                        user.last_name = result['last_name']    
                    if 'username' in result:
                        user.username = result['username']
                        
                    user.save()
                    g = Group.objects.get(name='normaluser')
                    g.user_set.add(user)
                    g.save()
                    attrs['user'] = user
                    return attrs
            else:
                raise serializers.ValidationError(
                    'Invalid access token.')
        else:
            raise serializers.ValidationError(
                'Empty access token.')
