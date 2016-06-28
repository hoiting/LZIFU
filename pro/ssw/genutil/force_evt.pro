function force_evt, parent_evt, ids, button=button, type=type, value=value
;
;+
;   Name: force_evt
;
;   Purpose: make new event structure for input into event routine 
;
;   Input Parameters:
;      parent_evt - parent event of caller
;      ids = list of widget ids to search for widget_value=value
;      
;   Keyword Parameters:
;      type - string describing type of output structure
;	      (widget_button, widget_slider, ...)
;    
;   History - slf 5-June-1992
;
;-
;
; assume desired button
values=get_wvalue(ids)
which=where(value eq values,count)
if count ne 0 then desired_id = ids(which)
if not keyword_set(type) then type='button'
case strupcase(type) of
   'BUTTON': begin
       out_str={widget_button}
       out_str.top=parent_evt.top
       out_str.id=desired_id(0)
       out_str.select=1
    endcase
    else:
endcase 
return, out_str
end
