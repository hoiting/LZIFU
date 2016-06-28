;+
; Project     : SOHO - CDS     
;                   
; Name        : MK_DFONT
;               
; Purpose     : make some uniformly useful fonts for planning software
;               
; Category    : utility
;               
; Explanation : 
;               
; Syntax      : IDL> mk_dfont,lfont=lfont,bfont=bfont
;    
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : See keywords
;
; Opt. Outputs: None
;               
; Keywords    : LFONT = a label font
;               BFONT = a button font
;               TFONT = a text font
;               DEFAULT = use default font if one of above does not exist
;                         (otherwise, used fixed font)
;
; History     : 17-Aug-1996,  D M Zarro - written
;               16-Feb-2004, Zarro (L-3Com/GSFC) - optimized with common
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro mk_dfont,lfont=lfont,bfont=bfont,tfont=tfont,default=default

common mk_dfont,last_lfont,last_bfont,last_tfont

if os_family(/lower) eq 'windows' then begin
 def_lfont='' & def_tfont='' & def_bfont=''
endif else begin
 def_lfont='-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1'
 def_bfont='-adobe-courier-bold-r-normal--20-140-100-100-m-110-iso8859-1'
 def_tfont='-adobe-courier-bold-r-normal--14-100-100-100-m-90-iso8859-1'
endelse

if arg_present(lfont) then begin
 if is_string(lfont,/blank) then lfont=strtrim(lfont,2) else lfont=def_lfont
 do_call=1b
 if exist(last_lfont) then begin
  if last_lfont eq lfont then do_call=0b
 endif
 if do_call then begin
  lfont = (get_dfont(lfont))[0]
  last_lfont=lfont
 endif
endif else lfont=''

if arg_present(bfont) then begin
 if is_string(bfont,/blank) then bfont=strtrim(bfont,2) else bfont=def_bfont
 do_call=1b
 if exist(last_bfont) then begin
  if last_bfont eq bfont then do_call=0b
 endif
 if do_call then begin
  bfont = (get_dfont(bfont))[0]
  last_bfont=bfont
 endif
endif else bfont=''

if arg_present(tfont) then begin
 if is_string(tfont,/blank) then tfont=strtrim(tfont,2) else tfont=def_tfont
 do_call=1b
 if exist(last_tfont) then begin
  if last_tfont eq tfont then do_call=0b
 endif
 if do_call then begin
  tfont = (get_dfont(tfont))[0]
  last_tfont=tfont
 endif
endif else tfont=''

return & end

