;+
; Project     : HESSI
;
; Name        : CLONE_VAR
;
; Purpose     : Clone a variable by saving it to an IDL save file
;               and then restoring it into a new copy of itself.
;               Useful for cloning objects, pointers, & structures.
;               Unnecessary for regular variables.
;
; Category    : utility objects pointers
;
; Syntax      : IDL> clone=clone_var(variable)
;
; Inputs      : VARIABLE = variable to clone
;
; Outputs     : CLONE = cloned copy
;
; History     : Written 29 Nov 2002, D. Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;
;-

function clone_var,variable

;-- save variable to a unique temporary file and then restore it

if not exist(variable) then return,-1
clone=variable
temp_file='temp'+get_rid()+'.sav'
temp_file=concat_dir(get_temp_dir(),temp_file)
save,file=temp_file,clone
restore,file=temp_file
file_delete,temp_file,/quiet
return,clone

end

