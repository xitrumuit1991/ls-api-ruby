$(document).ready(function () {
  $('.multiple-items').slick({
    infinite: true,
    slidesToShow: 5,
    slidesToScroll: 5
  });

  $('#modal-add-new-schedule').on('click', '.add-new-schedule', function(){
  	var html = '<div class="row m-t-10">';
        html += '<div class="col-sm-3">';
        html += '<input type="text" name="schedule[][date_start]" class="date start form-control" />';
        html += '</div>';
        html += '<div class="col-sm-2">';
        html += '<input type="text" name="schedule[][time_start]" class="time start form-control" />';
        html += '</div>';
        html += '<div class="col-sm-2">';
        html += '<input type="text" name="schedule[][time_end]" class="time end form-control" />';
        html += '</div>';
        html += '<div class="col-sm-3">';
        html += '<input type="text" name="schedule[][date_end]" class="date end form-control" />';
        html += '</div>';
        html += '<div class="col-sm-2">';
        html += '<button type="button" class="btn btn-success remove-schedule"><i class="fa fa-trash-o"></i></button>';
        html += '</div>';
        html += '</div>';
    $('#modal-add-new-schedule .schedules').append(html);

    $('#modal-add-new-schedule .time').timepicker({
	      'showDuration': true,
	      'timeFormat': 'g:ia'
	  });

	  $('#modal-add-new-schedule .date').datepicker({
	      'format': 'd/m/yyyy',
	      'autoclose': true
	  });
	  
	  $('#modal-add-new-schedule .row').datepair({
	  	defaultTimeDelta: 7200000
	  });
  });

  $('#modal-add-new-schedule').on('click', '.remove-schedule', function(){
  	$(this).parent().parent().remove();
	});
})