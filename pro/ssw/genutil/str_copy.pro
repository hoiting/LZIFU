function str_copy, str1, str2,_extra=extra
;
;+
;   Name: str_copy
;
;   Purpose: copy structures  - required when two structures are
;            identical in structure but differ in idl name
;            avoids conflicting data structure name
;
;   Input Parameters:
;      str1 - destination structure (template)
;      str2 - source structurei
;
;   Output: function return value is type str1 copy of str2 contents
;
;   History: slf, 10/24/91
;	     slf, 10/24/91 - streamlined recursive segment
;            6-Sep-05 Zarro (L-3Com/GSFC) - added STRUCT_ASSIGN
;
;   Method: recursive for nested structures
;
;

if (not is_struct(str1)) then return,-1
if (not is_struct(str2)) then return,str1

;-- use faster, better, robust struct_assign

if since_version('5.1') then begin
 struct_assign,str2,str1,_extra=extra
 return,str1
endif

for i=0,n_tags(str1) - 1 do $  
   if n_tags(str1.(i)) eq 0 then str1.(i)=str2.(i) else $ 
;     else its a structure, so recurse
      str1.(i)=str_copy(str1.(i),str2.(i))	
;
; return copied version
return,str1
end
