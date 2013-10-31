from rest_framework import serializers
from rest_framework.relations import RelatedField
from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note, Profile
from bg_order.models import Meal, Order, Request

from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = ('email', 'username', 'first_name', 'last_name',
                  'password', 'auth_token')
        read_only_fields = ('auth_token',)


class CategorySerializer(serializers.ModelSerializer):

    class Meta:
        model = Category
        read_only_fields = ('name', 'desc')


class ProfileSerializer(serializers.ModelSerializer):

    user = serializers.SerializerMethodField('get_user')

    def get_user(self, obj):
        return {
            'email': obj.user.email,
            'first_name': obj.user.first_name,
            'last_name': obj.user.last_name,
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
        return "no icon"

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
        return "no photo"

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
    dishes = DishSerializer(many=True)
    tables = OutletTableSerializer(many=True)

    class Meta:
        model = Outlet


class RatingSerializer(serializers.ModelSerializer):
    dish = RelatedField(many=True)
    user = RelatedField(many=True)

    class Meta:
        model = Rating


class ReviewSerializer(serializers.ModelSerializer):
    outlet = RelatedField(many=True)
    user = RelatedField(many=True)

    class Meta:
        model = Review


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
