function str_concat, str1, str2
;+
;   Name: str_concat
;
;   Purpose: allow concatenation of identical structures even though
;	     the structure name may differ
;
;   Input Parameters
;	str1 - first structure or structure array
;	str2 - second structure or structure array
;   Output: ;	function returns concatenated vector of structure name=str1
;
;   Method: uses str_copy which is recursive for nested structures
;
;   History: slf, 10/23/91
;	 2-Mar-94 (MDM) - Modified to create SXT history index portion
;			  if only one input has the .HIS portion
;			- Modified to use STR_COPY_TAGS instead of
;			  STR_COPY 
;-
;
val = his_exist(str1) + his_exist(str2)	;does history record exist in either input
;
if (val eq 1) then begin
    ;print, 'Case of generating .HIS'
    str1temp = str1
    str2temp = str2
    his_index, /enable
    his_index, str1temp		;append the .HIS if necessary
    his_index, str2temp
    out_str = str1temp(0)	;the output structure type
    out = [str_copy_tags(out_str, str1temp), str_copy_tags(out_str, str2temp)]
end else begin
    out_str = str1(0)		;the output structure type
    out = [str_copy_tags(out_str, str1), str_copy_tags(out_str, str2)]

    ;;str1name=tag_names(str1,/structure)
    ;;exe_string= 'temp=replicate({' + str1name + '},' + string(n_elements(str2)) + ') 
    ;;status=execute(exe_string)
    ;;new=str_copy(temp,str2)		; copy str2->temp, field for field using str_copy
    ;;return,[str1,new]			;return concatenated vector
end
;
return, out
end
