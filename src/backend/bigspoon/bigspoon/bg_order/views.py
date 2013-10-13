from django.shortcuts import render_to_response

def main(request):
    return render_to_response('bg_order/main.html')

def menu(request):
    return render_to_response('bg_order/menu.html')

def tables(request):
    return render_to_response('bg_order/tables.html')

def user(request):
    return render_to_response('bg_order/user.html')

def history(request):
    return render_to_response('bg_order/history.html')

def report(request):
    return render_to_response('bg_order/report.html')
