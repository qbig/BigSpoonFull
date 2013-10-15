from rest_framework import serializers
from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note
from django.contrib.auth import get_user_model

User = get_user_model()


class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ('url', 'email', 'first_name', 'last_name')


class RestaurantSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Restaurant
        fields = ('url', 'name', 'icon')


class OutletSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Outlet
        fields = ('url', 'name', 'desc')


class OutletTableSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Table
        fields = ('url', 'name')


class CategorySerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Category
        fields = ('url', 'name', 'desc')


class DishSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Dish
        fields = (
            'url', 'name', 'pos', 'desc', 'start_time',
            'end_time', 'price', 'photo', 'categories'
        )


class RatingSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Rating
        fields = ('url', 'user', 'dish', 'score')


class ReviewSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Review
        fields = ('url', 'user', 'outlet', 'score', 'feedback')


class NoteSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Note
        fields = ('url', 'user', 'outlet', 'note')
