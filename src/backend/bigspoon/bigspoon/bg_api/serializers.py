from rest_framework import serializers
from rest_framework.relations import RelatedField
from bg_inventory.models import Restaurant, Outlet, Table,\
    Category, Dish, Rating, Review, Note
from django.contrib.auth import get_user_model

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = ('email', 'first_name', 'last_name', 'password', 'auth_token')
        read_only_fields = ('auth_token',)


class CategorySerializer(serializers.ModelSerializer):

    class Meta:
        model = Category
        read_only_fields = ('name', 'desc')


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
