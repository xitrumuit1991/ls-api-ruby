(function(){var e;e=jQuery,e(document).ready(function(){return window.nestedFormEvents.insertFields=function(d,n,t){var o;return o=e(t).closest(".controls").siblings(".tab-content"),o.append(d),o.children().last()}}),e(document).on("nested:fieldAdded","form",function(d){var n,t,o,l,i,a,s;return t=d.field.addClass("tab-pane").attr("id","unique-id-"+(new Date).getTime()),l=e('<li><a data-toggle="tab" href="#'+t.attr("id")+'">'+t.children(".object-infos").data("object-label")+"</a></li>"),a=t.closest(".control-group"),n=a.children(".controls"),i=void 0!==n.data("nestedone"),o=n.children(".nav"),d=a.children(".tab-content"),s=n.find(".toggler"),o.append(l),e(window.document).trigger("rails_admin.dom_ready",[t,a]),l.children("a").tab("show"),i||o.select(":hidden").show("slow"),d.select(":hidden").show("slow"),s.addClass("active").removeClass("disabled").children("i").addClass("icon-chevron-down").removeClass("icon-chevron-right"),i?n.find(".add_nested_fields").removeClass("add_nested_fields").html(t.children(".object-infos").data("object-label")):void 0}),e(document).on("nested:fieldRemoved","form",function(e){var d,n,t,o,l,i,a,s;return o=e.field,l=o.closest(".control-group").children(".controls").children(".nav"),t=l.children("li").has("a[href=#"+o.attr("id")+"]"),a=o.closest(".control-group"),n=a.children(".controls"),i=void 0!==n.data("nestedone"),s=n.find(".toggler"),(t.next().length?t.next():t.prev()).children("a:first").tab("show"),t.remove(),0===l.children().length&&(l.select(":visible").hide("slow"),s.removeClass("active").addClass("disabled").children("i").removeClass("icon-chevron-down").addClass("icon-chevron-right")),i?(d=s.next(),d.addClass("add_nested_fields").html(d.data("add-label"))):void 0})}).call(this);