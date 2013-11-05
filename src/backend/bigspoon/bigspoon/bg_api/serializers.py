from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate
from django.utils import timezone

from rest_framework import serializers
from rest_framework.relations import RelatedField

from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note, Profile
from bg_order.models import Meal, Order, Request


User = get_user_model()


class UserSerializer(serializers.ModelSerializer):

    avatar_url = serializers.SerializerMethodField('get_avatar')

    def get_avatar(self, obj):
        if hasattr(obj, 'email'):
            return obj.avatar_url
        return 'None'

    class Meta:
        model = User
        fields = ('email', 'username', 'first_name', 'last_name',
                  'password', 'auth_token', 'avatar_url')
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
                'thumbnail': obj.photo.url_640x400,
            }
        return {
            'original': "media/restaurant/dishes/default.jpg",
            'thumbnail': "media/restaurant/dishes/default.jpg",
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

    def get_dishes(self, obj):
        now = timezone.now().time()
        current = obj.dishes.filter(
            start_time__lte=now,
            end_time__gte=now
        )
        return DishSerializer(current).data

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
    dish = DishSerializer(many=False)

    class Meta:
        model = Order


class MealSerializer(serializers.ModelSerializer):
    orders = OrderSerializer(many=True)

    class Meta:
        model = Meal
        read_only_fields = ('created', 'modified')


class MealDetailSerializer(serializers.ModelSerializer):

    class Meta:
        model = Meal


class RequestSerializer(serializers.ModelSerializer):

    class Meta:
        model = Request
        fields = ('table', 'note', 'request_type', 'is_active',
                  'finished', 'diner')
        read_only_fields = ('is_active', 'finished', 'diner')


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
