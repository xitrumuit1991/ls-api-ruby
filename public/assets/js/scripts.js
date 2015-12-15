 $(document).ready(function() {
    $('.datepicker').datepicker();
    //$('.cs-select').select2();
    var table = $('.datatable');
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
    $('#search-table').keyup(function() {
        table.fnFilter($(this).val());
    });

    $('.form-wizard-pure').bootstrapWizard({
        onTabShow: function(tab, navigation, index) {
            var $total = navigation.find('li').length;
            var $current = index + 1;

            // If it's the last tab then hide the last button and show the finish instead
            if ($current >= $total) {
                $('.form-wizard-pure').find('.pager .next').hide();
                $('.form-wizard-pure').find('.pager .finish').show();
                $('.form-wizard-pure').find('.pager .finish').removeClass('disabled');
            } else {
                $('.form-wizard-pure').find('.pager .next').show();
                $('.form-wizard-pure').find('.pager .finish').hide();
            }

            var li = navigation.find('li.active');

            var btnNext = $('.form-wizard-pure').find('.pager .next').find('button');
            var btnPrev = $('.form-wizard-pure').find('.pager .previous').find('button');

            // remove fontAwesome icon classes
            function removeIcons(btn) {
                btn.removeClass(function(index, css) {
                    return (css.match(/(^|\s)fa-\S+/g) || []).join(' ');
                });
            }

            if ($current > 1 && $current < $total) {

                var nextIcon = li.next().find('.fa');
                var nextIconClass = nextIcon.attr('class').match(/fa-[\w-]*/).join();

                removeIcons(btnNext);
                btnNext.addClass(nextIconClass + ' btn-animated from-left fa');

                var prevIcon = li.prev().find('.fa');
                var prevIconClass = prevIcon.attr('class').match(/fa-[\w-]*/).join();

                removeIcons(btnPrev);
                btnPrev.addClass(prevIconClass + ' btn-animated from-left fa');
            } else if ($current == 1) {
                // remove classes needed for button animations from previous button
                btnPrev.removeClass('btn-animated from-left fa');
                removeIcons(btnPrev);
            } else {
                // remove classes needed for button animations from next button
                btnNext.removeClass('btn-animated from-left fa');
                removeIcons(btnNext);
            }
        }
    });

    // load google map
    $(".modalMap").on('click', function(){
        var lat = $(this).data('lat');
        var lng = $(this).data('lng');
        var map = initGoogleMap(lat, lng);
        $("#modalSlideUp").on('shown.bs.modal', function(){
            google.maps.event.trigger(map, 'resize');
            map.setCenter(new google.maps.LatLng(lat, lng));
        });
    });

    //init google map
    function initGoogleMap(lat, lng) {
        var myLatlng = new google.maps.LatLng(lat, lng);
        var mapOptions = {
            center: myLatlng,
            zoom: 17,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
        var marker = new google.maps.Marker({
            position: myLatlng,
            map: map,
            title: 'Hello World!'
        });
        return map;
    }
 });