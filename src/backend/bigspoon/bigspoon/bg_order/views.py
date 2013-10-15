from django.views.generic import TemplateView, ListView, FormView

class StaffLogin(FormView):
    pass

class MainView(TemplateView):
    template_name = "bg_order/main.html"

# class MainView(ListView):
#     model = Order
#     template_name = "bg_order/main.html"
#     context_object_name = 'order'

class MenuView(TemplateView):
    template_name = "bg_order/menu.html"

class TableView(TemplateView):
    template_name = "bg_order/tables.html"

class UserView(TemplateView):
    template_name = "bg_order/user.html"

class HistoryView(TemplateView):
    template_name = "bg_order/history.html"

class ReportView(TemplateView):
    template_name = "bg_order/report.html"
