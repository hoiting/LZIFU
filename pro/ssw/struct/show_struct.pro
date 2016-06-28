;+
; Project     : SOHO - CDS     
;                   
; Name        : SHOW_STRUCT
;               
; Purpose     : Display contents and breakdown of an IDL structure.
;               
; Explanation : Displays in a widget the contents of a structure.  Embedded
;               structures are unpacked.
;               
; Use         : IDL> show_struct, str_name
;    
; Inputs      : str_name  - name of structure to be viewed.
;               
; Opt. Inputs : None
;               
; Outputs     : None
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : DSP_STRUCT
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, structure
;               
; Prev. Hist. : Just a packaged version of S V Haugan's DSP_STRUCT with the
;               /alone keyword.
;
; Written     : C D Pike, RAL, 21-Apr-94
;               
; Modified    : 
;
; Version     : Version 1, 21-Apr-94
;-            

pro show_struct, str

if datatype(str,1) ne 'Structure' then begin
   print,'Input variable must be of type -Structure-'
   return
endif

;
;  call original routine with /alone keyword set
;
dsp_struct,str,/alone


end
