from django import forms


class MenuDishForm(forms.Form):
    name = forms.CharField()
    description = forms.CharField(widget=forms.Textarea)

    pass
