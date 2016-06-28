;+
; Project     : SOHO - CDS     
;                   
; Name        : SAME_DATA()
;               
; Purpose     : Check if two variables are identical.
;               
; Explanation : Checks if the values contained in the 2 inputs are the same.
;               Works on any type of data input. 
;               
; Use         : IDL> if same_data(a,b) then print,'a and b are identical'
;    
; Inputs      : a  -  first input
;               b  -  second input
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns 1 for identity, 0 otherwise.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : MATCH_STRUCT
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, numerical
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 22-Feb-95
;               
; Modified    : Accept string arrays.  CDP, 9-Nov-95
;               Modified, 22-Nov-02, Zarro (EER/GSFC) 
;               - added call to more efficient same_data2 for IDL > 5.3
;
;-            

function same_data, a, b,_extra=extra

if since_version('5.4') then return,same_data2(a,b,_extra=extra)

;
;  get data type
;
typea = datatype(a,1)
typeb = datatype(b,1)
if typea ne typeb then return,0

case typea of

      'String': begin
                   if n_elements(a) gt 1 then begin
                      if n_elements(a) ne n_elements(b) then return,0
                      for i=0,n_elements(a)-1 do begin
                         if a(i) ne b(i) then return,0
                      endfor
                      return,1
                   endif
                   if a eq b then return,1 else return,0
                end

   'Structure': return, match_struct(a,b)

          else: begin
                   sa = size(a)
                   sb = size(b)
                   if sa(0) ne sb(0) then return, 0
                   if n_elements(sa) ne n_elements(sb) then return,0
                   for i=0,n_elements(sa)-1 do begin
                      if sa(i) ne sb(i) then return,0
                   endfor
                   stat = where( (a eq b) eq 1, npix)
                   if npix ne n_elements(a) then return, 0
                end
endcase
return,1

end

