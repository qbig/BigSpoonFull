from rest_framework import serializers
from rest_framework.relations import RelatedField
from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note, Profile
from bg_order.models import Meal, Order, Request

from django.contrib.auth import get_user_model

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    meals = RelatedField(many=True)
    requests = RelatedField(many=True)

    class Meta:
        model = User
        fields = ('email', 'first_name', 'last_name', 'password', 'auth_token')
        read_only_fields = ('auth_token',)


class CategorySerializer(serializers.ModelSerializer):

    class Meta:
        model = Category
        read_only_fields = ('name', 'desc')


class ProfileSerializer(serializers.ModelSerializer):

    user = serializers.SerializerMethodField('get_user')
    gender = serializers.SerializerMethodField('get_gender')
    is_vegetarian = serializers.SerializerMethodField('get_is_vegetarian')
    is_muslim = serializers.SerializerMethodField('get_is_muslim')
    favourite = CategorySerializer(many=True)

    def get_user(self, obj):
        return {
            'email': obj.user.email,
            'first_name': obj.user.first_name,
            'last_name': obj.user.last_name,
        }

    def get_gender(self, obj):
        return Profile.GENDER_TYPES_DIC[obj.gender]

    def get_is_vegetarian(self, obj):
        return Profile.YES_NO_CHOICES_DIC[obj.is_vegetarian]

    def get_is_muslim(self, obj):
        return Profile.YES_NO_CHOICES_DIC[obj.is_muslim]

    class Meta:
        model = Profile


class RestaurantSerializer(serializers.ModelSerializer):
    icon = serializers.SerializerMethodField('get_icon')

    def get_icon(self, obj):
        return {
            'original': obj.icon.url,
            'thumbnail': obj.icon.url_200x200,
        }

    class Meta:
        model = Restaurant
        read_only_fields = ('name',)


class DishSerializer(serializers.ModelSerializer):
    photo = serializers.SerializerMethodField('get_photo')
    categories = CategorySerializer(many=True)

    def get_photo(self, obj):
        return {
            'original': obj.photo.url,
            'thumbnail': obj.photo.url_640x400,
        }

    class Meta:
        model = Dish


class OutletListSerializer(serializers.ModelSerializer):
    restaurant = RestaurantSerializer(many=False)

    class Meta:
        model = Outlet
        read_only_fields = ('name', 'desc')


class OutletDetailSerializer(serializers.ModelSerializer):
    dishes = DishSerializer(many=True)

    class Meta:
        model = Outlet
        read_only_fields = ('name', 'desc')


class OutletTableSerializer(serializers.ModelSerializer):
    outlet = RelatedField(many=True)

    class Meta:
        model = Table
        fields = ('name', 'qrcode')
        read_only_fields = ('name', 'qrcode')


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
    outlet = RelatedField(many=True)
    user = RelatedField(many=True)

    class Meta:
        model = Note


class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        read_only_fields = ('created', 'modified')


class MealSerializer(serializers.ModelSerializer):
    orders = OrderSerializer(many=True)

    class Meta:
        model = Meal


class RequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Request
