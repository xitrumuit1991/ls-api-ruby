/*
 * jQuery UI Timepicker
 *
 * Copyright 2010-2013, Francois Gelinas
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * http://fgelinas.com/code/timepicker
 *
 * Depends:
 *	jquery.ui.core.js
 *  jquery.ui.position.js (only if position settngs are used)
 *
 * Change version 0.1.0 - moved the t-rex up here
 *
                                                  ____
       ___                                      .-~. /_"-._
      `-._~-.                                  / /_ "~o\  :Y
          \  \                                / : \~x.  ` ')
           ]  Y                              /  |  Y< ~-.__j
          /   !                        _.--~T : l  l<  /.-~
         /   /                 ____.--~ .   ` l /~\ \<|Y
        /   /             .-~~"        /| .    ',-~\ \L|
       /   /             /     .^   \ Y~Y \.^>/l_   "--'
      /   Y           .-"(  .  l__  j_j l_/ /~_.-~    .
     Y    l          /    \  )    ~~~." / `/"~ / \.__/l_
     |     \     _.-"      ~-{__     l  :  l._Z~-.___.--~
     |      ~---~           /   ~~"---\_  ' __[>
     l  .                _.^   ___     _>-y~
      \  \     .      .-~   .-~   ~>--"  /
       \  ~---"            /     ./  _.-'
        "-.,_____.,_  _.--~\     _.-~
                    ~~     (   _}       -Row
                           `. ~(
                             )  \
                            /,`--'~\--'~\
                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                             ->T-Rex<-
*/
!function($){function Timepicker(){this.debug=!0,this._curInst=null,this._disabledInputs=[],this._timepickerShowing=!1,this._inDialog=!1,this._dialogClass="ui-timepicker-dialog",this._mainDivId="ui-timepicker-div",this._inlineClass="ui-timepicker-inline",this._currentClass="ui-timepicker-current",this._dayOverClass="ui-timepicker-days-cell-over",this.regional=[],this.regional[""]={hourText:"Hour",minuteText:"Minute",amPmText:["AM","PM"],closeButtonText:"Done",nowButtonText:"Now",deselectButtonText:"Deselect"},this._defaults={showOn:"focus",button:null,showAnim:"fadeIn",showOptions:{},appendText:"",beforeShow:null,onSelect:null,onClose:null,timeSeparator:":",periodSeparator:" ",showPeriod:!1,showPeriodLabels:!0,showLeadingZero:!0,showMinutesLeadingZero:!0,altField:"",defaultTime:"now",myPosition:"left top",atPosition:"left bottom",onHourShow:null,onMinuteShow:null,hours:{starts:0,ends:23},minutes:{starts:0,ends:55,interval:5},rows:4,showHours:!0,showMinutes:!0,optionalMinutes:!1,showCloseButton:!1,showNowButton:!1,showDeselectButton:!1},$.extend(this._defaults,this.regional[""]),this.tpDiv=$('<div id="'+this._mainDivId+'" class="ui-timepicker ui-widget ui-helper-clearfix ui-corner-all " style="display: none"></div>')}function extendRemove(e,t){$.extend(e,t);for(var i in t)(null==t[i]||void 0==t[i])&&(e[i]=t[i]);return e}$.extend($.ui,{timepicker:{version:"0.3.2"}});var PROP_NAME="timepicker",tpuuid=(new Date).getTime();$.extend(Timepicker.prototype,{markerClassName:"hasTimepicker",log:function(){this.debug&&console.log.apply("",arguments)},_widgetTimepicker:function(){return this.tpDiv},setDefaults:function(e){return extendRemove(this._defaults,e||{}),this},_attachTimepicker:function(target,settings){var inlineSettings=null;for(var attrName in this._defaults){var attrValue=target.getAttribute("time:"+attrName);if(attrValue){inlineSettings=inlineSettings||{};try{inlineSettings[attrName]=eval(attrValue)}catch(err){inlineSettings[attrName]=attrValue}}}var nodeName=target.nodeName.toLowerCase(),inline="div"==nodeName||"span"==nodeName;target.id||(this.uuid+=1,target.id="tp"+this.uuid);var inst=this._newInst($(target),inline);inst.settings=$.extend({},settings||{},inlineSettings||{}),"input"==nodeName?(this._connectTimepicker(target,inst),this._setTimeFromField(inst)):inline&&this._inlineTimepicker(target,inst)},_newInst:function(e,t){var i=e[0].id.replace(/([^A-Za-z0-9_-])/g,"\\\\$1");return{id:i,input:e,inline:t,tpDiv:t?$('<div class="'+this._inlineClass+' ui-timepicker ui-widget  ui-helper-clearfix"></div>'):this.tpDiv}},_connectTimepicker:function(e,t){var i=$(e);t.append=$([]),t.trigger=$([]),i.hasClass(this.markerClassName)||(this._attachments(i,t),i.addClass(this.markerClassName).keydown(this._doKeyDown).keyup(this._doKeyUp).bind("setData.timepicker",function(e,i,s){t.settings[i]=s}).bind("getData.timepicker",function(e,i){return this._get(t,i)}),$.data(e,PROP_NAME,t))},_doKeyDown:function(e){var t=$.timepicker._getInst(e.target),i=!0;if(t._keyEvent=!0,$.timepicker._timepickerShowing)switch(e.keyCode){case 9:$.timepicker._hideTimepicker(),i=!1;break;case 13:return $.timepicker._updateSelectedValue(t),$.timepicker._hideTimepicker(),!1;case 27:$.timepicker._hideTimepicker();break;default:i=!1}else 36==e.keyCode&&e.ctrlKey?$.timepicker._showTimepicker(this):i=!1;i&&(e.preventDefault(),e.stopPropagation())},_doKeyUp:function(e){var t=$.timepicker._getInst(e.target);$.timepicker._setTimeFromField(t),$.timepicker._updateTimepicker(t)},_attachments:function(e,t){var i=this._get(t,"appendText"),s=this._get(t,"isRTL");t.append&&t.append.remove(),i&&(t.append=$('<span class="'+this._appendClass+'">'+i+"</span>"),e[s?"before":"after"](t.append)),e.unbind("focus.timepicker",this._showTimepicker),e.unbind("click.timepicker",this._adjustZIndex),t.trigger&&t.trigger.remove();var n=this._get(t,"showOn");if(("focus"==n||"both"==n)&&(e.bind("focus.timepicker",this._showTimepicker),e.bind("click.timepicker",this._adjustZIndex)),"button"==n||"both"==n){var r=this._get(t,"button");$(r).bind("click.timepicker",function(){return $.timepicker._timepickerShowing&&$.timepicker._lastInput==e[0]?$.timepicker._hideTimepicker():t.input.is(":disabled")||$.timepicker._showTimepicker(e[0]),!1})}},_inlineTimepicker:function(e,t){var i=$(e);i.hasClass(this.markerClassName)||(i.addClass(this.markerClassName).append(t.tpDiv).bind("setData.timepicker",function(e,i,s){t.settings[i]=s}).bind("getData.timepicker",function(e,i){return this._get(t,i)}),$.data(e,PROP_NAME,t),this._setTimeFromField(t),this._updateTimepicker(t),t.tpDiv.show())},_adjustZIndex:function(e){e=e.target||e;var t=$.timepicker._getInst(e);t.tpDiv.css("zIndex",$.timepicker._getZIndex(e)+1)},_showTimepicker:function(e){if(e=e.target||e,"input"!=e.nodeName.toLowerCase()&&(e=$("input",e.parentNode)[0]),!$.timepicker._isDisabledTimepicker(e)&&$.timepicker._lastInput!=e){$.timepicker._hideTimepicker();var t=$.timepicker._getInst(e);$.timepicker._curInst&&$.timepicker._curInst!=t&&$.timepicker._curInst.tpDiv.stop(!0,!0);var i=$.timepicker._get(t,"beforeShow");extendRemove(t.settings,i?i.apply(e,[e,t]):{}),t.lastVal=null,$.timepicker._lastInput=e,$.timepicker._setTimeFromField(t),$.timepicker._inDialog&&(e.value=""),$.timepicker._pos||($.timepicker._pos=$.timepicker._findPos(e),$.timepicker._pos[1]+=e.offsetHeight);var s=!1;$(e).parents().each(function(){return s|="fixed"==$(this).css("position"),!s});var n={left:$.timepicker._pos[0],top:$.timepicker._pos[1]};if($.timepicker._pos=null,t.tpDiv.css({position:"absolute",display:"block",top:"-1000px"}),$.timepicker._updateTimepicker(t),!t.inline&&"object"==typeof $.ui.position){t.tpDiv.position({of:t.input,my:$.timepicker._get(t,"myPosition"),at:$.timepicker._get(t,"atPosition"),collision:"flip"});var n=t.tpDiv.offset();$.timepicker._pos=[n.top,n.left]}if(t._hoursClicked=!1,t._minutesClicked=!1,n=$.timepicker._checkOffset(t,n,s),t.tpDiv.css({position:$.timepicker._inDialog&&$.blockUI?"static":s?"fixed":"absolute",display:"none",left:n.left+"px",top:n.top+"px"}),!t.inline){var r=$.timepicker._get(t,"showAnim"),a=$.timepicker._get(t,"duration"),u=function(){$.timepicker._timepickerShowing=!0;var e=$.timepicker._getBorders(t.tpDiv);t.tpDiv.find("iframe.ui-timepicker-cover").css({left:-e[0],top:-e[1],width:t.tpDiv.outerWidth(),height:t.tpDiv.outerHeight()})};$.timepicker._adjustZIndex(e),$.effects&&$.effects[r]?t.tpDiv.show(r,$.timepicker._get(t,"showOptions"),a,u):t.tpDiv.show(r?a:null,u),r&&a||u(),t.input.is(":visible")&&!t.input.is(":disabled")&&t.input.focus(),$.timepicker._curInst=t}}},_getZIndex:function(e){for(var t,i,s=$(e),n=0;s.length&&s[0]!==document;)t=s.css("position"),("absolute"===t||"relative"===t||"fixed"===t)&&(i=parseInt(s.css("zIndex"),10),isNaN(i)||0===i||i>n&&(n=i)),s=s.parent();return n},_refreshTimepicker:function(e){var t=this._getInst(e);t&&this._updateTimepicker(t)},_updateTimepicker:function(e){e.tpDiv.empty().append(this._generateHTML(e)),this._rebindDialogEvents(e)},_rebindDialogEvents:function(e){var t=$.timepicker._getBorders(e.tpDiv),i=this;e.tpDiv.find("iframe.ui-timepicker-cover").css({left:-t[0],top:-t[1],width:e.tpDiv.outerWidth(),height:e.tpDiv.outerHeight()}).end().find(".ui-timepicker-minute-cell").unbind().bind("click",{fromDoubleClick:!1},$.proxy($.timepicker.selectMinutes,this)).bind("dblclick",{fromDoubleClick:!0},$.proxy($.timepicker.selectMinutes,this)).end().find(".ui-timepicker-hour-cell").unbind().bind("click",{fromDoubleClick:!1},$.proxy($.timepicker.selectHours,this)).bind("dblclick",{fromDoubleClick:!0},$.proxy($.timepicker.selectHours,this)).end().find(".ui-timepicker td a").unbind().bind("mouseout",function(){$(this).removeClass("ui-state-hover"),-1!=this.className.indexOf("ui-timepicker-prev")&&$(this).removeClass("ui-timepicker-prev-hover"),-1!=this.className.indexOf("ui-timepicker-next")&&$(this).removeClass("ui-timepicker-next-hover")}).bind("mouseover",function(){i._isDisabledTimepicker(e.inline?e.tpDiv.parent()[0]:e.input[0])||($(this).parents(".ui-timepicker-calendar").find("a").removeClass("ui-state-hover"),$(this).addClass("ui-state-hover"),-1!=this.className.indexOf("ui-timepicker-prev")&&$(this).addClass("ui-timepicker-prev-hover"),-1!=this.className.indexOf("ui-timepicker-next")&&$(this).addClass("ui-timepicker-next-hover"))}).end().find("."+this._dayOverClass+" a").trigger("mouseover").end().find(".ui-timepicker-now").bind("click",function(e){$.timepicker.selectNow(e)}).end().find(".ui-timepicker-deselect").bind("click",function(e){$.timepicker.deselectTime(e)}).end().find(".ui-timepicker-close").bind("click",function(e){$.timepicker._hideTimepicker()}).end()},_generateHTML:function(e){var t,i,s,n,r=1==this._get(e,"showPeriod"),a=1==this._get(e,"showPeriodLabels"),u=1==this._get(e,"showLeadingZero"),o=1==this._get(e,"showHours"),c=1==this._get(e,"showMinutes"),p=this._get(e,"amPmText"),l=this._get(e,"rows"),d=0,h=0,m=0,_=0,k=0,g=0,f=Array(),v=this._get(e,"hours"),$=null,b=0,T=this._get(e,"hourText"),w=this._get(e,"showCloseButton"),C=this._get(e,"closeButtonText"),D=this._get(e,"showNowButton"),I=this._get(e,"nowButtonText"),M=this._get(e,"showDeselectButton"),x=this._get(e,"deselectButtonText"),y=w||D||M;for(t=v.starts;t<=v.ends;t++)f.push(t);if($=Math.ceil(f.length/l),a){for(b=0;b<f.length;b++)f[b]<12?m++:_++;b=0,d=Math.floor(m/f.length*l),h=Math.floor(_/f.length*l),l!=d+h&&(m&&(!_||!d||h&&m/d>=_/h)?d++:h++),k=Math.min(d,1),g=d+1,$=0==d?Math.ceil(_/h):0==h?Math.ceil(m/d):Math.ceil(Math.max(m/d,_/h))}if(n='<table class="ui-timepicker-table ui-widget-content ui-corner-all"><tr>',o){for(n+='<td class="ui-timepicker-hours"><div class="ui-timepicker-title ui-widget-header ui-helper-clearfix ui-corner-all">'+T+'</div><table class="ui-timepicker">',i=1;l>=i;i++){for(n+="<tr>",i==k&&a&&(n+='<th rowspan="'+d.toString()+'" class="periods" scope="row">'+p[0]+"</th>"),i==g&&a&&(n+='<th rowspan="'+h.toString()+'" class="periods" scope="row">'+p[1]+"</th>"),s=1;$>=s;s++)a&&g>i&&f[b]>=12?n+=this._generateHTMLHourCell(e,void 0,r,u):(n+=this._generateHTMLHourCell(e,f[b],r,u),b++);n+="</tr>"}n+="</table></td>"}if(c&&(n+='<td class="ui-timepicker-minutes">',n+=this._generateHTMLMinutes(e),n+="</td>"),n+="</tr>",y){var S='<tr><td colspan="3"><div class="ui-timepicker-buttonpane ui-widget-content">';D&&(S+='<button type="button" class="ui-timepicker-now ui-state-default ui-corner-all"  data-timepicker-instance-id="#'+e.id.replace(/\\\\/g,"\\")+'" >'+I+"</button>"),M&&(S+='<button type="button" class="ui-timepicker-deselect ui-state-default ui-corner-all"  data-timepicker-instance-id="#'+e.id.replace(/\\\\/g,"\\")+'" >'+x+"</button>"),w&&(S+='<button type="button" class="ui-timepicker-close ui-state-default ui-corner-all"  data-timepicker-instance-id="#'+e.id.replace(/\\\\/g,"\\")+'" >'+C+"</button>"),n+=S+"</div></td></tr>"}return n+="</table>"},_updateMinuteDisplay:function(e){var t=this._generateHTMLMinutes(e);e.tpDiv.find("td.ui-timepicker-minutes").html(t),this._rebindDialogEvents(e)},_generateHTMLMinutes:function(e){var t,i,s="",n=this._get(e,"rows"),r=Array(),a=this._get(e,"minutes"),u=null,o=0,c=1==this._get(e,"showMinutesLeadingZero"),p=this._get(e,"onMinuteShow"),l=this._get(e,"minuteText");for(a.starts||(a.starts=0),a.ends||(a.ends=59),t=a.starts;t<=a.ends;t+=a.interval)r.push(t);if(u=Math.round(r.length/n+.49),p&&0==p.apply(e.input?e.input[0]:null,[e.hours,e.minutes]))for(o=0;o<r.length;o+=1)if(t=r[o],p.apply(e.input?e.input[0]:null,[e.hours,t])){e.minutes=t;break}for(s+='<div class="ui-timepicker-title ui-widget-header ui-helper-clearfix ui-corner-all">'+l+'</div><table class="ui-timepicker">',o=0,i=1;n>=i;i++){for(s+="<tr>";i*u>o;){var t=r[o],d="";void 0!==t&&(d=10>t&&c?"0"+t.toString():t.toString()),s+=this._generateHTMLMinuteCell(e,t,d),o++}s+="</tr>"}return s+="</table>"},_generateHTMLHourCell:function(e,t,i,s){var n=t;t>12&&i&&(n=t-12),0==n&&i&&(n=12),10>n&&s&&(n="0"+n);var r="",a=!0,u=this._get(e,"onHourShow");return void 0==t?r='<td><span class="ui-state-default ui-state-disabled">&nbsp;</span></td>':(u&&(a=u.apply(e.input?e.input[0]:null,[t])),r=a?'<td class="ui-timepicker-hour-cell" data-timepicker-instance-id="#'+e.id.replace(/\\\\/g,"\\")+'" data-hour="'+t.toString()+'"><a class="ui-state-default '+(t==e.hours?"ui-state-active":"")+'">'+n.toString()+"</a></td>":'<td><span class="ui-state-default ui-state-disabled '+(t==e.hours?" ui-state-active ":" ")+'">'+n.toString()+"</span></td>")},_generateHTMLMinuteCell:function(e,t,i){var s="",n=!0,r=this._get(e,"onMinuteShow");return r&&(n=r.apply(e.input?e.input[0]:null,[e.hours,t])),s=void 0==t?'<td><span class="ui-state-default ui-state-disabled">&nbsp;</span></td>':n?'<td class="ui-timepicker-minute-cell" data-timepicker-instance-id="#'+e.id.replace(/\\\\/g,"\\")+'" data-minute="'+t.toString()+'" ><a class="ui-state-default '+(t==e.minutes?"ui-state-active":"")+'" >'+i+"</a></td>":'<td><span class="ui-state-default ui-state-disabled" >'+i+"</span></td>"},_destroyTimepicker:function(e){var t=$(e),i=$.data(e,PROP_NAME);if(t.hasClass(this.markerClassName)){var s=e.nodeName.toLowerCase();$.removeData(e,PROP_NAME),"input"==s?(i.append.remove(),i.trigger.remove(),t.removeClass(this.markerClassName).unbind("focus.timepicker",this._showTimepicker).unbind("click.timepicker",this._adjustZIndex)):("div"==s||"span"==s)&&t.removeClass(this.markerClassName).empty()}},_enableTimepicker:function(e){var t=$(e),i=t.attr("id"),s=$.data(e,PROP_NAME);if(t.hasClass(this.markerClassName)){var n=e.nodeName.toLowerCase();if("input"==n){e.disabled=!1;var r=this._get(s,"button");$(r).removeClass("ui-state-disabled").disabled=!1,s.trigger.filter("button").each(function(){this.disabled=!1}).end()}else if("div"==n||"span"==n){var a=t.children("."+this._inlineClass);a.children().removeClass("ui-state-disabled"),a.find("button").each(function(){this.disabled=!1})}this._disabledInputs=$.map(this._disabledInputs,function(e){return e==i?null:e})}},_disableTimepicker:function(e){var t=$(e),i=$.data(e,PROP_NAME);if(t.hasClass(this.markerClassName)){var s=e.nodeName.toLowerCase();if("input"==s){var n=this._get(i,"button");$(n).addClass("ui-state-disabled").disabled=!0,e.disabled=!0,i.trigger.filter("button").each(function(){this.disabled=!0}).end()}else if("div"==s||"span"==s){var r=t.children("."+this._inlineClass);r.children().addClass("ui-state-disabled"),r.find("button").each(function(){this.disabled=!0})}this._disabledInputs=$.map(this._disabledInputs,function(t){return t==e?null:t}),this._disabledInputs[this._disabledInputs.length]=t.attr("id")}},_isDisabledTimepicker:function(e){if(!e)return!1;for(var t=0;t<this._disabledInputs.length;t++)if(this._disabledInputs[t]==e)return!0;return!1},_checkOffset:function(e,t,i){var s=e.tpDiv.outerWidth(),n=e.tpDiv.outerHeight(),r=e.input?e.input.outerWidth():0,a=e.input?e.input.outerHeight():0,u=document.documentElement.clientWidth+$(document).scrollLeft(),o=document.documentElement.clientHeight+$(document).scrollTop();return t.left-=this._get(e,"isRTL")?s-r:0,t.left-=i&&t.left==e.input.offset().left?$(document).scrollLeft():0,t.top-=i&&t.top==e.input.offset().top+a?$(document).scrollTop():0,t.left-=Math.min(t.left,t.left+s>u&&u>s?Math.abs(t.left+s-u):0),t.top-=Math.min(t.top,t.top+n>o&&o>n?Math.abs(n+a):0),t},_findPos:function(e){for(var t=this._getInst(e),i=this._get(t,"isRTL");e&&("hidden"==e.type||1!=e.nodeType);)e=e[i?"previousSibling":"nextSibling"];var s=$(e).offset();return[s.left,s.top]},_getBorders:function(e){var t=function(e){return{thin:1,medium:2,thick:3}[e]||e};return[parseFloat(t(e.css("border-left-width"))),parseFloat(t(e.css("border-top-width")))]},_checkExternalClick:function(e){if($.timepicker._curInst){var t=$(e.target);t[0].id==$.timepicker._mainDivId||0!=t.parents("#"+$.timepicker._mainDivId).length||t.hasClass($.timepicker.markerClassName)||t.hasClass($.timepicker._triggerClass)||!$.timepicker._timepickerShowing||$.timepicker._inDialog&&$.blockUI||$.timepicker._hideTimepicker()}},_hideTimepicker:function(e){var t=this._curInst;if(t&&(!e||t==$.data(e,PROP_NAME))&&this._timepickerShowing){var i=this._get(t,"showAnim"),s=this._get(t,"duration"),n=function(){$.timepicker._tidyDialog(t),this._curInst=null};$.effects&&$.effects[i]?t.tpDiv.hide(i,$.timepicker._get(t,"showOptions"),s,n):t.tpDiv["slideDown"==i?"slideUp":"fadeIn"==i?"fadeOut":"hide"](i?s:null,n),i||n(),this._timepickerShowing=!1,this._lastInput=null,this._inDialog&&(this._dialogInput.css({position:"absolute",left:"0",top:"-100px"}),$.blockUI&&($.unblockUI(),$("body").append(this.tpDiv))),this._inDialog=!1;var r=this._get(t,"onClose");r&&r.apply(t.input?t.input[0]:null,[t.input?t.input.val():"",t])}},_tidyDialog:function(e){e.tpDiv.removeClass(this._dialogClass).unbind(".ui-timepicker")},_getInst:function(e){try{return $.data(e,PROP_NAME)}catch(t){throw"Missing instance data for this timepicker"}},_get:function(e,t){return void 0!==e.settings[t]?e.settings[t]:this._defaults[t]},_setTimeFromField:function(e){if(e.input.val()!=e.lastVal){var t=this._get(e,"defaultTime"),i="now"==t?this._getCurrentTimeRounded(e):t;if(0==e.inline&&""!=e.input.val()&&(i=e.input.val()),i instanceof Date)e.hours=i.getHours(),e.minutes=i.getMinutes();else{var s=e.lastVal=i;if(""==i)e.hours=-1,e.minutes=-1;else{var n=this.parseTime(e,s);e.hours=n.hours,e.minutes=n.minutes}}$.timepicker._updateTimepicker(e)}},_optionTimepicker:function(e,t,i){var s=this._getInst(e);if(2==arguments.length&&"string"==typeof t)return"defaults"==t?$.extend({},$.timepicker._defaults):s?"all"==t?$.extend({},s.settings):this._get(s,t):null;var n=t||{};"string"==typeof t&&(n={},n[t]=i),s&&(this._curInst==s&&this._hideTimepicker(),extendRemove(s.settings,n),this._updateTimepicker(s))},_setTimeTimepicker:function(e,t){var i=this._getInst(e);i&&(this._setTime(i,t),this._updateTimepicker(i),this._updateAlternate(i,t))},_setTime:function(e,t,i){var s=e.hours,n=e.minutes;if(t instanceof Date)e.hours=t.getHours(),e.minutes=t.getMinutes();else{var t=this.parseTime(e,t);e.hours=t.hours,e.minutes=t.minutes}s==e.hours&&n==e.minutes||i||e.input.trigger("change"),this._updateTimepicker(e),this._updateSelectedValue(e)},_getCurrentTimeRounded:function(e){var t=new Date,i=t.getMinutes(),s=5*Math.round(i/5);return t.setMinutes(s),t},parseTime:function(e,t){var i=new Object;if(i.hours=-1,i.minutes=-1,!t)return"";var s=this._get(e,"timeSeparator"),n=this._get(e,"amPmText"),r=this._get(e,"showHours"),a=this._get(e,"showMinutes"),u=this._get(e,"optionalMinutes"),o=1==this._get(e,"showPeriod"),c=t.indexOf(s);if(-1!=c?(i.hours=parseInt(t.substr(0,c),10),i.minutes=parseInt(t.substr(c+1),10)):!r||a&&!u?!r&&a&&(i.minutes=parseInt(t,10)):i.hours=parseInt(t,10),r){var p=t.toUpperCase();i.hours<12&&o&&-1!=p.indexOf(n[1].toUpperCase())&&(i.hours+=12),12==i.hours&&o&&-1!=p.indexOf(n[0].toUpperCase())&&(i.hours=0)}return i},selectNow:function(e){var t=$(e.target).attr("data-timepicker-instance-id"),i=$(t),s=this._getInst(i[0]),n=new Date;s.hours=n.getHours(),s.minutes=n.getMinutes(),this._updateSelectedValue(s),this._updateTimepicker(s),this._hideTimepicker()},deselectTime:function(e){var t=$(e.target).attr("data-timepicker-instance-id"),i=$(t),s=this._getInst(i[0]);s.hours=-1,s.minutes=-1,this._updateSelectedValue(s),this._hideTimepicker()},selectHours:function(e){var t=$(e.currentTarget),i=t.attr("data-timepicker-instance-id"),s=parseInt(t.attr("data-hour")),n=e.data.fromDoubleClick,r=$(i),a=this._getInst(r[0]),u=1==this._get(a,"showMinutes");if($.timepicker._isDisabledTimepicker(r.attr("id")))return!1;t.parents(".ui-timepicker-hours:first").find("a").removeClass("ui-state-active"),t.children("a").addClass("ui-state-active"),a.hours=s;var o=this._get(a,"onMinuteShow");return o&&this._updateMinuteDisplay(a),this._updateSelectedValue(a),a._hoursClicked=!0,(a._minutesClicked||n||0==u)&&$.timepicker._hideTimepicker(),!1},selectMinutes:function(e){var t=$(e.currentTarget),i=t.attr("data-timepicker-instance-id"),s=parseInt(t.attr("data-minute")),n=e.data.fromDoubleClick,r=$(i),a=this._getInst(r[0]),u=1==this._get(a,"showHours");return $.timepicker._isDisabledTimepicker(r.attr("id"))?!1:(t.parents(".ui-timepicker-minutes:first").find("a").removeClass("ui-state-active"),t.children("a").addClass("ui-state-active"),a.minutes=s,this._updateSelectedValue(a),a._minutesClicked=!0,a._hoursClicked||n||0==u?($.timepicker._hideTimepicker(),!1):!1)},_updateSelectedValue:function(e){var t=this._getParsedTime(e);e.input&&(e.input.val(t),e.input.trigger("change"));var i=this._get(e,"onSelect");return i&&i.apply(e.input?e.input[0]:null,[t,e]),this._updateAlternate(e,t),t},_getParsedTime:function(e){if(-1==e.hours&&-1==e.minutes)return"";(e.hours<e.hours.starts||e.hours>e.hours.ends)&&(e.hours=0),(e.minutes<e.minutes.starts||e.minutes>e.minutes.ends)&&(e.minutes=0);var t="",i=1==this._get(e,"showPeriod"),s=1==this._get(e,"showLeadingZero"),n=1==this._get(e,"showHours"),r=1==this._get(e,"showMinutes"),a=1==this._get(e,"optionalMinutes"),u=this._get(e,"amPmText"),o=e.hours?e.hours:0,c=e.minutes?e.minutes:0,p=o?o:0,l="";-1==p&&(p=0),-1==c&&(c=0),i&&(0==e.hours&&(p=12),e.hours<12?t=u[0]:(t=u[1],p>12&&(p-=12)));var d=p.toString();s&&10>p&&(d="0"+d);var h=c.toString();return 10>c&&(h="0"+h),n&&(l+=d),!n||!r||a&&0==h||(l+=this._get(e,"timeSeparator")),!r||a&&0==h||(l+=h),n&&t.length>0&&(l+=this._get(e,"periodSeparator")+t),l},_updateAlternate:function(e,t){var i=this._get(e,"altField");i&&$(i).each(function(e,i){$(i).val(t)})},_getTimeAsDateTimepicker:function(e){var t=this._getInst(e);return-1==t.hours&&-1==t.minutes?"":((t.hours<t.hours.starts||t.hours>t.hours.ends)&&(t.hours=0),(t.minutes<t.minutes.starts||t.minutes>t.minutes.ends)&&(t.minutes=0),new Date(0,0,0,t.hours,t.minutes,0))},_getTimeTimepicker:function(e){var t=this._getInst(e);return this._getParsedTime(t)},_getHourTimepicker:function(e){var t=this._getInst(e);return void 0==t?-1:t.hours},_getMinuteTimepicker:function(e){var t=this._getInst(e);return void 0==t?-1:t.minutes}}),$.fn.timepicker=function(e){$.timepicker.initialized||($(document).mousedown($.timepicker._checkExternalClick).find("body").append($.timepicker.tpDiv),$.timepicker.initialized=!0);var t=Array.prototype.slice.call(arguments,1);return"string"!=typeof e||"getTime"!=e&&"getTimeAsDate"!=e&&"getHour"!=e&&"getMinute"!=e?"option"==e&&2==arguments.length&&"string"==typeof arguments[1]?$.timepicker["_"+e+"Timepicker"].apply($.timepicker,[this[0]].concat(t)):this.each(function(){"string"==typeof e?$.timepicker["_"+e+"Timepicker"].apply($.timepicker,[this].concat(t)):$.timepicker._attachTimepicker(this,e)}):$.timepicker["_"+e+"Timepicker"].apply($.timepicker,[this[0]].concat(t))},$.timepicker=new Timepicker,$.timepicker.initialized=!1,$.timepicker.uuid=(new Date).getTime(),$.timepicker.version="0.3.2",window["TP_jQuery_"+tpuuid]=$}(jQuery);