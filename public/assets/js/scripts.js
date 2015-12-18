$(document).ready(function () {
    $("#form-work").validate();
    $('.select2').select2();
    // $('.datetimepicker').datetimepicker();
    $('#datepicker-range, #datepicker-component, #datepicker-component2').datepicker();

    //start date & end date
    /*$('#start_date').datetimepicker();
    $('#end_date').datetimepicker({
        useCurrent: false //Important! See issue #1075
    });
    $("#start_date").on("dp.change", function (e) {
        $('#end_date').data("DateTimePicker").minDate(e.date);
    });
    $("#end_date").on("dp.change", function (e) {
        $('#start_date').data("DateTimePicker").maxDate(e.date);
    });*/

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
        "iDisplayLength": 10
    };
    table.dataTable(settings);

    // search box for table
    $('#search-table').keyup(function () {
        table.fnFilter($(this).val());
    });

    // check all for table
    $('#check-all').on('click', function () {
        if ($(this).is(':checked')) {
            $('table.data-table .check-all').prop('checked', true);
        } else {
            $('table.data-table .check-all').prop('checked', false);
        }
    });
    
    // update status
    $('table.data-table').on('change', '.status', function(){
        var result = $(this).attr('id').split('-');
        var status = ($(this).is(':checked')) ? 1 : 0;
        
        data = { id: result[1], status: status, li_token: token };
        $.post(module_url + '/ajax_update_status', data, function(resp){
            console.log(resp.flag);
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
    $('.slug').on('change', function(){
        data = { text: $(this).val(), li_token: token };
        $.post(base_url + 'ajax/ajax_get_slug', data, function(resp){
            $("input[name='slug']").val(resp);
        });
    });

    // get slug
    $('.slug-lang').on('change', function(){
        data = { text: $(this).val(), li_token: token };
        $.post(base_url + 'ajax/ajax_get_slug', data, function(resp){
            $("input[name='code']").val(resp);
        });
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

});

function BrowseServer(inputId){
    // You can use the "CKFinder" class to render CKFinder in a page:
    var finder = new CKFinder();
    
    finder.basePath = '/ckfinder/';	// The path for the installation of CKFinder (default = "/ckfinder/").
    finder.selectActionFunction = SetFileField;
    finder.selectActionData = inputId;
    finder.popup();
    // It can also be done in a single line, calling the "static"
    // popup( basePath, width, height, selectFunction ) function:
    // CKFinder.popup( '../', null, null, SetFileField ) ;
    //
    // The "popup" function can also accept an object as the only argument.
    // CKFinder.popup( { basePath : '../', selectActionFunction : SetFileField } ) ;
}
// This is a sample function which is called when a file is selected in CKFinder.
function SetFileField( fileUrl, data ){
    
    document.getElementById( data['selectActionData'] ).value = fileUrl;
}