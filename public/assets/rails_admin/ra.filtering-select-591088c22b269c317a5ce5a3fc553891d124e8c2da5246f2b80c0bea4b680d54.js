!function(t){t.widget("ra.filteringSelect",{options:{createQuery:function(t){return{query:t}},minLength:0,searchDelay:200,remote_source:null,source:null,xhr:!1},_create:function(){var e=this,n=this.element.hide(),o=n.children(":selected"),i=o.val()?o.text():"";this.options.xhr?this.options.source=this.options.remote_source:this.options.source=n.children("option").map(function(){return{label:t(this).text(),value:this.value}}).toArray();var a=t('<div class="input-group filtering-select col-sm-2" style="float:left"></div>'),s=this.input=t('<input type="text">').val(i).addClass("form-control ra-filtering-select-input").attr("style",n.attr("style")).show().autocomplete({delay:this.options.searchDelay,minLength:this.options.minLength,source:this._getSourceFunction(this.options.source),select:function(o,i){var a=t("<option></option>").attr("value",i.item.id).attr("selected","selected").text(i.item.value);n.html(a),n.trigger("change",i.item.id),e._trigger("selected",o,{item:a}),t(e.element.parents(".controls")[0]).find(".update").removeClass("disabled")},change:function(o,i){if(!i.item){var a=new RegExp("^"+t.ui.autocomplete.escapeRegex(t(this).val())+"$","i"),l=!1;if(n.children("option").each(function(){return t(this).text().match(a)?(this.selected=l=!0,!1):void 0}),!l||""==t(this).val())return t(this).val(null),n.html(t('<option value="" selected="selected"></option>')),s.data("ui-autocomplete").term="",t(e.element.parents(".controls")[0]).find(".update").addClass("disabled"),!1}}}).keyup(function(){0==t(this).val().length&&(n.html(t('<option value="" selected="selected"></option>')),n.trigger("change"))});n.attr("placeholder")&&s.attr("placeholder",n.attr("placeholder")),s.data("ui-autocomplete")._renderItem=function(e,n){return t("<li></li>").data("ui-autocomplete-item",n).append(t("<a></a>").html(n.html||n.id)).appendTo(e)};var l=this.button=t('<span class="input-group-btn"><label class="btn btn-info dropdown-toggle" data-toggle="dropdown" aria-expanded="false" title="Show All Items" role="button"><span class="caret"></span><span class="ui-button-text">&nbsp;</span></label></span>').click(function(){return s.autocomplete("widget").is(":visible")?void s.autocomplete("close"):(s.autocomplete("search",""),void s.focus())});a.append(s).append(l).insertAfter(n)},_getResultSet:function(e,n,o){var i=new RegExp(t.ui.autocomplete.escapeRegex(e.term),"i"),a=function(e,n){return n.length>0?t.map(e.split(n),function(e,n){return t("<span></span>").text(e).html()}).join(t("<strong></strong>").text(n)[0].outerHTML):t("<span></span>").text(e).html()};return t.map(n,function(t,n){return(t.id||t.value)&&(o||i.test(t.label))?{html:a(t.label||t.id,e.term),value:t.label||t.id,id:t.id||t.value}:void 0})},_getSourceFunction:function(e){var n=this,o=0;return t.isArray(e)?function(t,o){o(n._getResultSet(t,e,!1))}:"string"==typeof e?function(i,a){this.xhr&&this.xhr.abort(),this.xhr=t.ajax({url:e,data:n.options.createQuery(i.term),dataType:"json",autocompleteRequest:++o,success:function(t,e){this.autocompleteRequest===o&&a(n._getResultSet(i,t,!0))},error:function(){this.autocompleteRequest===o&&a([])}})}:e},destroy:function(){this.input.remove(),this.button.remove(),this.element.show(),t.Widget.prototype.destroy.call(this)}})}(jQuery);