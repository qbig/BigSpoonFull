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
            obj.bill_time.date().strftime("%Y/%m/%d"),
            (now.date() - obj.bill_time.date()).days)

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


class SearchDishSerializer(serializers.Serializer):
    name = serializers.CharField(required=True)


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
                    if 'email' in result :
                        user = User.objects.get(email=result['email'])
                    else :
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
                    try: 
                        user.username = result['username']
                        user.first_name = result['first_name']
                        user.last_name = result['last_name']
                        user.email = result['email']                
                    except:
                        logger.error('Failed for retrieve fb fields')
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
