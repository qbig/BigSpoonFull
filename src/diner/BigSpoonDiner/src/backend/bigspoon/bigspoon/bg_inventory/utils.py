from django.contrib import messages
from django.shortcuts import render

from bg_inventory.models import Outlet, Dish
from bg_inventory.forms import DishCSVForm

from datetime import datetime
from decimal import Decimal
import csv


# dish csv file functions
def _handle_csv_file(f, exclude_first_line=True):
    """@params f: filehandler"""

    # Split lines of the Files
    raw_data = f.read().splitlines()

    # Remove first line
    if exclude_first_line:
        del raw_data[0]

    # read csv content
    uploaded_csv = csv.reader(raw_data)

    # Create the banklog object
    for row in uploaded_csv:
        if len(row) < 8:
            raise Exception("number of columns wrong.")
        try:
            o = Outlet.objects.get(pk=int(row[0].strip()))
        except Outlet.DoesNotExist:
            raise Exception("outlet doesn't exist.")
        dish = Dish(
            outlet=o,
            name=row[1].strip(),
            pos=row[2].strip(),
            desc=row[3].strip(),
            start_time=datetime.strptime(row[4].strip(), "%H:%M:%S").time(),
            end_time=datetime.strptime(row[5].strip(), "%H:%M:%S").time(),
            price=Decimal(row[6].strip()),
            quantity=int(row[7].strip())
        )
        dish.save()


def import_dish_csv(request):
    if request.method == 'POST':
        form = DishCSVForm(request.POST, request.FILES)
        if form.is_valid():
            f = request.FILES['csv_file']
            exclude_first_line = request.POST.get('exclude_first_line', False)
            try:
                _handle_csv_file(f, exclude_first_line)
            except Exception as e:
                error = "The given csv file format is wrong.\n Error:%s" % e
                messages.error(request, error)
            else:
                status = "Dishes has been imported."
                messages.success(request, status)
    else:
        form = DishCSVForm()

    return render(
        request,
        'admin/dish-import.html',
        {
            'form': form,
            'title': 'Import Dish CSV',
        })
