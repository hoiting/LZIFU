;+
; Project     : SOHO - CDS     
;                   
; Name        : PS_LONG
;               
; Purpose     : To stretch plotting area when device is PostScript printer.
;               
; Explanation : Resets plotting area using device command.  If the environment
;               variable US_FUNNY_PAPER is defined then the size is adjusted
;               from A4 to US size.
;               
; Use         : IDL> ps_long
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
; Side effects: None
;               
; Category    : Util,  plotting
;               
; Prev. Hist. : From Yohkoh routine by R D Bentley.
;
; Written     : CDS version by C D Pike, RAL, 21-Apr-94
;               
; Modified    : 
;
; Version     : Version 1, 21-Apr-94
;-            
pro	ps_long,dummy

;
;  only activate if PostScript is defined plotting device
;
if !d.name eq 'PS' then begin
   squash = getenv('US_FUNNY_PAPER')
   if squash ne '' then begin
      device,ysiz=23.,yoffset=3.		;US sized paper
   endif else begin 
      device,ysiz=25.,yoffset=3.		;A4 sized paper
   endelse
endif else begin
   print,'Plotting device is not PostScript.  No action taken.'
endelse

return
end

