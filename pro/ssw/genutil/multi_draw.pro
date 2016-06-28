function multi_draw, xsize, ysize , labels=labels, title=title, $
	view_map = view_map, event_options=event_options, text=text
;
;+
; NAME: Multi_draw
;
; PURPOSE:
;	create multiple draw widgets for display   
;	size of draw areas are variable 
;
; INPUT PARAMETERS (positional):
;	XSIZE - vector of draw widget X dimensions  
;	YSIZE - [optional] - if present, vector of draw widget Y
;		dimenstion - if absent, all widgets are square
;		of size = (Xsize x Xsize)
; OPTIONAL INPUT PARAMETERS (keyword):
;	Labels - string array containing label names
;	Title  - title for top level widget - ignored if embedded
;
; OUTPUT:
;	Function returns structure of type Multi_Draw
;	contains widget IDs of created widgets for control
;
;
; History: slf, 7/91
;-
if n_params() eq 1 then ysize=xsize		; square default
if not keyword_set (view_map) then view_map = $
	[[indgen(n_elements(xsize))],[indgen(n_elements(xsize))]]
if not keyword_set (title)  then title  = 'Multidraw'
if not keyword_set (labels) then labels = 'Sequence# ' + $
	sindgen(n_elements(xsize)+1)
labels=strcompress(labels)
;
nregions = n_elements(xsize)

; *** put these structure definitions in common widget area
; create nested structure to contain widet information
draw_str=make_str('{dummy, base:0L, label:0L, button:0L, draw:0L}')
text_str=make_str('{dummy, base:0L, label:0L, text:0L}')
;
draw_str_name = tag_names(draw_str,/structure)
text_str_name = tag_names(text_str,/structure)
;
multi_draw_str='{dummy, top:0L, parent:0L, option:0L,' + 	$
		 'id:"",number:n_elements(xsize), ' + 		$
	         'view_map:' + fmt_tag(size(view_map)) + ',' +	$
	         'views:replicate({' + draw_str_name + '},' + 	$
		  string(n_elements(xsize))+ '),' +		$
		 'text:{' + text_str_name +  '}}'
multi_draw_str=make_str(multi_draw_str)
;
temp=draw_str
;
base=widget_base(/column,title=title)			; format as row
basea=widget_base(base,/row)

if keyword_set (event_options) then  $
   xmenu, event_options, basea, uvalue=indgen(n_elements(event_options)), $
	/exclusive,/frame
;
rowsize=0
for i=0, n_elements(xsize)-1 do begin
   basex = widget_base(basea,/column,/frame)
   labelx= widget_label(basex,value=labels(i))
   buttonx=widget_button(basex,value='Select', uvalue=labels(i))
   drawx = widget_draw(basex, /button_events, /frame, $
			xsize=xsize(i), ysize=ysize(i))
   temp.base=basex
   temp.label=labelx
   temp.button=buttonx
   temp.draw=drawx
   multi_draw_str.views(i)=temp
   rowsize = rowsize + xsize(i)
   if rowsize gt 756 then begin
	basea=widget_base(base,/row)
	rowsize=0
   endif
endfor
;
if keyword_set (text) then begin
   text_base=widget_base(base,/column,/frame)
   text_label=widget_label(text_base)
   text = widget_text(text_base,ysize=4)
   multi_draw_str.text.base=text_base
   multi_draw_str.text.label=text_label
   multi_draw_str.text.text=text
endif
;
multi_draw_str.top = base
multi_draw_str.number = nregions
multi_draw_str.view_map = view_map
widget_control,base,/realize
widget_control,base,set_uvalue=multi_draw_str
return , multi_draw_str
end
