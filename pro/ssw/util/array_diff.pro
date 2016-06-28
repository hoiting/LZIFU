function array_diff, arr1, arr2, ndiff, $
       type_only=type_only, ignore_type=ignore_type
;+
;   Name:  arr_diff
;
;   Purpose: boolean function - arrays different? (string/struct/numeric OK)
;
;   Input Parameteters:
;      arr1, arr2 - to arrays to compare
;  
;   Output Parameters:
;      ndiff - number of differences
;
;   Output:
;      function returns 1 if there are ANY differences
;                       
;   Keyword Parameters:
;      ignore_type - ignore numeric type (dont worry about TYPE only differences
;                                         for numeric comparisons)
; 
;   Calling Sequence:
;      IDL> different=array_diff(array1, array2)
;
;   Calling Examples:
;      IDL> print,array_diff(replicate(!x,10),replicate(!y,10))    ;structure
;              1
;      IDL> print,array_diff(replicate(!x,10),replicate(!x,10))
;              0
;      IDL> print,array_diff(sindgen(10),sindgen(10))              ;striings
;              0
;      IDL> print,array_diff(sindgen(10),alphagen(10))   
;              1
;      IDL> print,array_diff(indgen(10),findgen(10))               ;numeric
;              1
;      IDL> print,array_diff(indgen(10),findgen(10),/ignore_type)  
;          0
;
;   History:
;      12-August-2000 - S.L. Freeland - package a few useful checks
;
;-

t1=data_chk(arr1,/type)
t2=data_chk(arr2,/type)

ne1=n_elements(arr1)
ne2=n_elements(arr2)
retval=1                                 ; assume different
if n_params() lt 2 then begin 
   box_message,['Need 2 things to compare',$
                'IDL> diff=array_diff(array1, array2)']
   return,retval
endif

ndiff=max([ne1,ne2])                     ; init ndifferences
samene=ne1 eq ne2                        ; 
ignore_type=keyword_set(ignore_type)

case 1 of                                ; nelem are same, then continue
   1-samene:                             ; nelem different? then done
   t1 eq 7 and t2 eq 7: begin            ; string check 
      dd=where( arr1 ne arr2,dcnt)
      retval=dcnt gt 0
   endcase
   t1 eq 8 and t2 eq 8: begin 
      for i=0, ne1-1 do $ 
         retval=retval+str_diff(arr1(i),arr2(i))     ; structures diff?
      retval=retval gt 1                             ; why>1? - because init=1
   endcase
   t1 ge 7 or t2 ge 7:                               ; mixed non-numerics (=>diff)
   else: begin                                       ; numberic? compare
      ss=where(arr1 ne arr2, dcnt)       
      retval=(dcnt ne 0) or  ((t1 ne t2)*(1-ignore_type))
   endelse
endcase


return,retval
end
