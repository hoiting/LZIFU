
;+
; NAME:
;              st2num
; PURPOSE:
;              convert string variable into numeric array
; CATEGORY:
;              utility
; CALLING SEQUENCE:
;              output=stnum(input,status)
; INPUTS:
;              input=string variable, e.g. '1,2,3,4,5'
; OPTIONAL INPUT PARAMETERS:
;              none
; OUTPUTS:
;              output=numeric array, e.g. [1,2,3,4,5]
; OPTIONAL OUTPUT PARAMETERS:
;              np = no of elements in output
;              status = 1 if conversion successful else 0
; SIDE EFFECTS:
;              none
; RESTRICTIONS:
;              input must contain numeric characters and no ascii
; PROCEDURE:
;              uses execute function to add '[' before first character 
;              and ']' after last.
; MODIFICATION HISTORY:
;              written Apr '88 (DMZ, ARC)
;-

function st2num,input,np,status
on_error,1
if input eq '' then input='0'          ;handle null case     
input=strtrim(input,2)
status=execute('output = ['+input+']') 
if not status then begin             ;handle erroneous input
 output=input & np=0
 message,'conversion failed',/continue
endif else begin
 s=size(output)
 if s(0) eq 0 then output=replicate(output,1)  ;convert scalar to vector
 np=n_elements(output)
endelse
return,output
end
