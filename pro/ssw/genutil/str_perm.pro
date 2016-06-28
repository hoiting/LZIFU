function str_perm, arr1, arr2, delimit, delim=delim
;
;+
;   Name: str_perm
;
;   Purpose: return string array which contains all permutations of
;	     the concatenation of arr1 and arr2
;      
;   Input Parameters:
;      arr1, arr2 - arrays to concatenate
;
;   History:
;      slf 1-apr-93
;-
on_error,2
if keyword_set(delim) then del=delim
sarr1=size(arr1)
if sarr1(sarr1(0) + 1) ne 7 then begin
   message,/info,'input parmaters must be string type...
   return,''
endif else begin
   case n_params() of
     1: arr2 = strarr(n_elements(arr1))
     3: del=delimit
     else:
   endcase
endelse
if n_elements(del) eq 0 then del = ''    
permarr=mkdarr(indgen(n_elements(arr1)),indgen(n_elements(arr2)))
return,arr1(permarr(0,*)) + del + arr2(permarr(1,*))
end

