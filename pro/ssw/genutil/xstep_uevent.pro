pro xstep_uevent,event
;
;+
;   Name: xstep_uevent
;   
;   Purpose: handle events in xstepper utility window 
;
;   History: slf - 30-April-92
;
;   Common Blocks:
;      xstepper_blk
;-
;

@xstepper.common

case event_name(event) of 
   "BUTTON": zoom(4)=get_wuvalue(event.id)	;update zoom factor
   "DRAW": mapx,event.top			;hide window
endcase 
;
return
end
