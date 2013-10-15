from rest_framework import serializers
from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note
from django.contrib.auth import get_user_model

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = ('email', 'first_name', 'last_name', 'password', 'auth_token')
        read_only_fields = ('auth_token',)


class RestaurantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Restaurant
        fields = ('name', 'icon')
        read_only_fields = ('name', 'icon')


class OutletSerializer(serializers.ModelSerializer):
    class Meta:
        model = Outlet
        fields = ('name', 'desc')
        read_only_fields = ('name', 'desc')


class OutletTableSerializer(serializers.ModelSerializer):
    class Meta:
        model = Table
        fields = ('name', 'qrcode')
        read_only_fields = ('name', 'qrcode')


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('name', 'desc')
        read_only_fields = ('name', 'desc')


class DishSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dish
        fields = (
            'name', 'pos', 'desc', 'start_time',
            'end_time', 'price', 'photo', 'categories'
        )


class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rating
        fields = ('user', 'dish', 'score')


class ReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = ('user', 'outlet', 'score', 'feedback')


class NoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Note
        fields = ('user', 'outlet', 'note')
