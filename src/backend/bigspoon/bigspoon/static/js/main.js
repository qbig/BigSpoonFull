var container = document.querySelector('#main');

var msnry = new Masonry( container, {
  // options
  itemSelector: '.item'
});

$('#id_start_time').timepicker();
$('#id_end_time').timepicker();