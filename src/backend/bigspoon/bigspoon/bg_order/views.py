from django.views.generic import TemplateView

class MainView(TemplateView):
    template_name = "bg_order/main.html"

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
