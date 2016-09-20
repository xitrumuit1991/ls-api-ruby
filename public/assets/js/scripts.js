$(document).ready(function () {
		$("#form-work").validate();
		$('.select2').select2();
		$('.datetimepicker').datetimepicker({format: 'DD/MM/YYYY LT'});
		$('.datepicker').datepicker({format: 'dd/mm/yyyy'});

		//start date & end date
		$('#start_date').datetimepicker({format: 'DD/MM/YYYY LT'});
		$('#end_date').datetimepicker({
			format: 'DD/MM/YYYY LT',
			useCurrent: false //Important! See issue #1075
		});
		$("#start_date").on("dp.change", function (e) {
			$('#end_date').data("DateTimePicker").minDate(e.date);
		});
		$("#end_date").on("dp.change", function (e) {
			$('#start_date').data("DateTimePicker").maxDate(e.date);
		});

		// check modal show
		var modal = window.location.hash
		if(modal !== undefined && modal !== "" && modal.search('modal') > 0){
			$(modal).modal('show');
		}

		// setup data table
		var table = $('.data-table');
		var settings = {
				"sDom": "<'table-responsive't><'row'<p i>>",
				"sPaginationType": "bootstrap",
				"destroy": true,
				"scrollCollapse": true,
				"oLanguage": {
						"sLengthMenu": "_MENU_ ",
						"sInfo": "Showing <b>_START_ to _END_</b> of _TOTAL_ entries"
				},
				"iDisplayLength": 25
		};
		table.dataTable(settings);

		// search box for table
		$('#search-table').keyup(function () {
				table.fnFilter($(this).val());
		});

		// check all for table
		$('#check-all').on('click', function () {
			if ($(this).is(':checked')) {
					$('#data-table table .check-all').prop('checked', true);
			} else {
					$('#data-table table .check-all').prop('checked', false);
			}
		});
		
		// handle sort
		var field = Common.getQueryString('field');
		var sort = Common.getQueryString('sort');
		if(field !== '' && field !== null && sort !== '' && sort !== null){
			$('table.dataTable').find('[data-field="'+ field +'"]').removeClass('sorting').addClass('sorting_' + sort);
		}

		// table sort
		$('table.dataTable').on('click', 'thead th', function(){
			if($(this).hasClass('sorting'))
				$(this).removeClass('sorting').addClass('sorting_asc');
			else
				$(this).toggleClass("sorting_asc sorting_desc");

			var sort = $(this).attr('class').split("_")[1];
			var field = $(this).data('field');
			$('#sort').val(sort);
			$('#field').val(field);
			$('#form-search').submit();
		});
		
		// update status
		$('#data-table table').on('change', '.handle-checkbox', function(){
				var result = $(this).attr('id').split('-');
				var field  = $(this).data('field');
				var value  = $(this).is(':checked') ? 1 : 0;
				
				var data = {};
				data["attrs"] = {};
				data["attrs"][field] = value;
				$.post(module_url + '/ajax_update_handle_checkbox/' + result[1], data, function(resp){
						console.log(resp);
				}, 'json');
		});
		
		// restore multiple
		$('.multiple-action').on('click', function(){
				if(!$('.check-all').is(':checked')) return false;
				
				if(confirm('Are you sure ?')){
						action = $(this).data('action');
						$('#data-table').attr("action", module_url + '/' + action);
						$('#data-table').submit();
				}
				else return false;
		});
		
		// delete multiple
		$('#delete-all').on('click', function(){
				if(!$('.check-all').is(':checked')) return false;
				
				if(confirm('Are you sure ?')){
						$('#data-table').submit();
				}
				else return false;
		});
		
		// get slug
		$('form .slug').on('keyup', function(){
				var slug = getSlug($(this).val(), { lang: 'vn' });
				$("input[name*='slug']").val(slug);
		});

		$('#add-browse').on('click', function(event) {
				event.preventDefault();
				var html = '';
				var num = $(this).attr('data-val');
				html += '<div class="col-sm-12" style="margin-top: 20px">';
				html += '<div class="col-sm-4">';
				html += '<input type="text" name="media[1]['+num+']" class="form-control" placeholder="BrowseServer ..." id="image'+num+'" readonly onclick="BrowseServer(\'image'+num+'\');"/>';
				html += '</div>';
				html += '</div>';
				num ++;
				$(this).attr('data-val', num);
				$('.input-browse-server').append(html);
		});
		
		// select2 multiple
		$('.select2-multiple').select2()
				.on("select2-selecting", function(e) {
						data = { selected: e.val , li_token: token };
						$.post(module_url + '/ajax_add_select_multiple/' + $(this).data('id'), data, function(resp){
								console.log(resp.flag);
						}, 'json');
				})
				.on("select2-removed", function(e) {
						data = { selected: e.val, li_token: token };
						$.post(module_url + '/ajax_delete_select_multiple/' + $(this).data('id'), data, function(resp){
								console.log(resp.flag);
						}, 'json');
				});
		var url = $(".search-key").attr('data-url');
		$(".search-key").select2({
			minimumInputLength: 3,
			ajax: {
				url: url,
				dataType: 'json',
				type: "GET",
				quietMillis: 50,
				data: function (term) {
					return {
						key: term.term
					};
				},
				processResults: function (data) {
					return {
						results: $.map(data, function (item) {
								return {
									text: item.name,
									id: item.id
								}
						})
					};
				}
			}
		});

});