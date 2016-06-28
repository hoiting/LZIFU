;+
; Project     : SOHO - CDS     
;                   
; Name        : REM_MULT_CHAR()
;               
; Purpose     : Function to remove multiple characters from a string. 
;               
; Explanation : Same as STRCOMPRESS only works on all characters.
;               
; Use         : result = rem_mult_char(string [, char ,/all])  
;
;    
; Inputs      : string - string variable in which to compress all multiple
;                        characters
;               
; Opt. Inputs : char   - character, multiple occurrences of which are to be
;                        replaced. Default is space
;               
; Outputs     : Function returns compressed string
;               
; Opt. Outputs: None
;               
; Keywords    : ALL - if present all occurrences of the named character will
;                     be deleted.
;
; Calls       : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, string
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 6-Mar-95
;               
; Modified    : Handle edge effects.  CDP, 10-mar-95
;
; Version     : Version 2, 10-Mar-95
;-            

function rem_mult_char, in_str, char, all=all

; 
;  on error return to caller
;
On_error,2

;
;  check have all parameters
;
if n_params() eq 0 then begin
   print,"Use:  IDL> text = 'This__is_untidy____spacing'"
   print,"      IDL> print,rem_mult_char(text,'_')"
   print,'  prints --> This_is_untidy_spacing'
   return,''
endif


;
;  default character is space
;
if n_elements(char) eq 0 then char = ' '

;
;  add bits to handle edge effects
;
if char ne '?' then str = '?'+in_str+'?' else str = '+'+in_str+'+'

;
;  break it up
;
text = str_sep(str,char)

;
;  kill duplicates
;
n = where(text ne '')
if n(0) ge 0 then text = text(n)

;
;   put it back together
;
arr = text(0)
if keyword_set(all) then begin
   for i=1,n_elements(text)-1 do arr = arr+text(i)
endif else begin
   for i=1,n_elements(text)-1 do arr = arr+char+text(i)
endelse

;
;  and return it (first knock off edge enhancements)
;
return,strmid(arr,1,(1 > strlen(arr)-2))

end
