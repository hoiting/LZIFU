;+
; Project     : SOHO - CDS     
;                   
; Name        : FMT_VECT()
;               
; Purpose     : Formats a vector (any length) into a parenthesized string.
;               
; Explanation : This function returns the given vector in parenthesized 
;               coordinates as in the form (X,Y).  No limit on the number 
;               of dimensions.  Also note that the vector does not need to 
;               be numbers.  It may also be a string vector.  e.g. ['X','Y']
;               
; Use         : IDL> tmp = VECT( vctr, [ form, FORMAT = , DELIM =  ] )
;    
; Inputs      : VCTR      The vector to be displayed  e.g. [56,44]
;               
; Opt. Inputs : FORM      This may be used instead of the keyword FORMAT
;               
; Outputs     : tmp       A returned string of the parenthesized vector
;               
; Opt. Outputs: 
;               
; Keywords    : FORMAT    Allows the specification of a format for the 
;                         elements.  e.g.: VECT([2,3],format='(f7.1)') 
;                         gives '(2.0,3.0)'
;
;               DELIM     Specifies the delimeter.  The default is ',' but
;                         other useful examples might be ', ' or ':'
;
; Calls       : NUM2STR
;               
; Restrictions: 
;               
; Side effects: 
;               
; Category    : 
;               
; Prev. Hist. : Original VECT, 29-Aug-91 by E. Deutsch 
;
; Written     : E Deutsch
;               
; Modified    : CDS version by  C D Pike, RAL, 13-May-93
;               Add /no_parentheses keyword.  CDP, 15-Nov-95
;
; Version     : Version 2, 15-Nov-1995
;-            

function fmt_vect,vctr,form,format=format,delim=delim,$
                            no_parentheses=no_parentheses

;
;  check input parameters
;
if (n_params(0) lt 1) then begin
    print,'Use:  IDL> stringvar = fmt_vect(vector,[FORMAT],[FORMAT=])'
    print,"e.g.: IDL> tmp = fmt_vect([512,512]) & print,'Center: ',tmp"
    return,''
endif

;
;  defaults
;
if (n_params(0) lt 2) then FORM=''
if (n_elements(vctr) lt 1) then return,''
if (n_elements(Format) eq 0) then Format=''
if (n_elements(delim) eq 0) then delim=','
if (FORM ne '') then Format=FORM

;
;  do the formatting
;
if not keyword_set(no_parentheses) then tmp='(' else tmp = ''
for i=0,n_elements(vctr)-1 do begin
   sep=delim
   if (i eq 0) then sep=''
   if (Format eq '') then begin
      tmp=tmp+sep+num2str(vctr(i)) 
   endif else begin
      tmp=tmp+sep+num2str(vctr(i),Format=Format)
   endelse
endfor    

;
;  add the final parenthesis
;

if not keyword_set(no_parentheses) then tmp=tmp+')'

return,tmp

end
