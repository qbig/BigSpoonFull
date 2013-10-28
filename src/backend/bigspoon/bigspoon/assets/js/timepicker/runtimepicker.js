$('#id_start_time').timepicker({'scrollDefaultNow': true, 'timeFormat': 'H:i:s' });
$('#id_end_time').timepicker({'scrollDefaultNow': true, 'timeFormat': 'H:i:s' });

//For id_form-0123-start_time and id_form-0123-end_time
$('[id^=id_form-][id$=-start_time]').timepicker({'scrollDefaultNow': true, 'timeFormat': 'H:i:s' });
$('[id^=id_form-][id$=-end_time]').timepicker({'scrollDefaultNow': true, 'timeFormat': 'H:i:s' });
