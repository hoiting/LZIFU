;+
; Project     : SOHO - CDS     
;                   
; Name        : PS_RESET
;               
; Purpose     : Resets PostScript plotting area to Portrait, normal size.
;               
; Explanation : The antidote to PS_LONG.
;               
; Use         : IDL> ps_reset
;    
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : None
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: Returns PostScript device to Portrait mode also.
;               
; Category    : Util, device
;               
; Prev. Hist. : Yohkoh routine by R D Bentley.
;
; Written     : CDS version by C D Pike, RAL, 21-Apr-94
;               
; Modified    : 
;
; Version     : Version 1, 21-Apr-94
;-            

pro	ps_reset,dummy

if !d.name eq 'PS' then begin
   device,/inches,ysize=5.,yoffset=5.,/portrait
endif else begin
   print,'Device is not PostScript, no action taken.'
endelse

return
end
