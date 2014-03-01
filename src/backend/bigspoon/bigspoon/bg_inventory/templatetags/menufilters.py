from django import template

register = template.Library()


@register.filter(name='addcss')
def addcss(value, arg):
    return value.as_widget(attrs={'class': arg})

@register.filter(name='key')
def key(d, key_name):
    try:
        value = d[key_name]
    except:
        from django.conf import settings
        value = settings.TEMPLATE_STRING_IF_INVALID
    return value
