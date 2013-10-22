from django import forms
from django.contrib.auth import get_user_model
from django.utils.translation import ugettext_lazy as _

from bg_inventory.models import Dish

User = get_user_model()


class BGUserCreationForm(forms.ModelForm):

    password1 = forms.CharField(label=_("Password"),
                                widget=forms.PasswordInput)
    password2 = forms.CharField(label=_("Password confirmation"),
                                widget=forms.PasswordInput,
                                help_text=_("Enter the same password as above,"
                                            " for verification."))

    def clean_password2(self):
        password1 = self.cleaned_data.get("password1")
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise forms.ValidationError(
                self.error_messages['password_mismatch'])
        return password2

    def save(self, commit=True):
        user = super(BGUserCreationForm, self).save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user

    class Meta:
        model = User
        fields = ('email', 'username',)


class DishCreateForm(forms.ModelForm):

    class Meta:
        model = Dish
        fields = ['outlet', 'name', 'pos', 'start_time', 'end_time', 'desc',
                  'price', 'photo']
        widgets = {
            'start_time': forms.TimeInput(attrs={'format': '%H:%M:%S'}),
            'end_time': forms.TimeInput(attrs={'format': '%H:%M:%S'}),
        }
