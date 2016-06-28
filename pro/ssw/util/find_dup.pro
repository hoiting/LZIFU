;+
; Project     : SOHO - CDS     
;                   
; Name        : FIND_DUP()
;               
; Purpose     : Function to identify duplicate values in a vector. 
;               
; Explanation : The function returns a vector pointing to duplicated values
;               in the input array such that
;                         print,a(find_dup(a))
;               will print a list of duplicate values. But beware that the
;               function returns a value -1 if no duplicates are found.
;               
; Use         : result = find_dup(vector)  
;
; Inputs      : vector - vector of values from which duplicates are to be found
;               
; Opt. Inputs : None
;               
; Outputs     : A vector of subscripts in 'vector' is returned.  Each subscript
;               points to a duplicated value. If no duplicates are found, a
;               value -1 is returned.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, misc
;               
; Prev. Hist. : Based on REM_DUP by D. Lindler  Mar. 87
;
; Written     : CDS version by C D Pike, RAL, 12-Nov-93
;               
; Modified    : Use BSORT to maintain order.  CDP, 9-Nov-94
;		Version 3, 22-May-1997, William Thompson, GSFC
;			Changed so that loop variable is a long integer
;		Version 4, 27-May-1997, William Thompson, GSFC
;			Changed so that NDUP is also long
;
; Version     : Version 4, 27-May-1997
;-            

function find_dup, a

; 
;  on error return to caller
;
On_error,2

;
; number of input parameters supplied
;
npar = N_params()              

;
;  if no parameters given then prompt with help
;
if npar EQ 0 then begin
   print,'Syntax -  b = find_dup(a)
   return, -1
endif

;
;  number of elements in input
;
n = N_elements(a)  

;
;  if only one value then not much to chose from
;
if n lt 2 then return, lonarr(1)    


;
;  sort in ascending order
; 
sub = bsort(a)   

;
;  sort input vector
;
aa = a(sub)   
 
;
;  values to keep
;
dup = lonarr(n)

;
; set first value and initialise the counter
; 
val = aa(0)                      
ndup = -1L

;
;  loop over aa
;

for i = 1L,n-1L do begin
   if aa(i) ne val then begin
      val = aa(i)
   endif else begin
      ndup = ndup + 1
      dup(ndup) = sub(i)
   endelse
endfor

;
;  trim the storage, sort it and return subscripts in original vector
; 
if ndup ge 0 then begin
   dup = dup(0:ndup)
   return,dup(bsort(dup))
endif else begin
   return, -1
endelse              
 
end
