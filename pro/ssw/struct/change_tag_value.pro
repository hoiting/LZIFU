;+
; Project     : HESSI
;
; Name        : change_tag_value
;
; Purpose     : Change a tag value in a structure
;
; Explanation : Restricted to changing one tag value per call.  If tag is not found in structure,
;	found keyword is 0 and structure is unchanged.  Will recurse through nested structures.
;	If  tag is a pointer, then if pointer is valid, puts new value in pointer, otherwise makes a new
;	pointer to the value.
;	NOTE:  new value must be same type as old value.  For a more relaxed routine, use rep_tag_value
;
; Use         : change_tag_value, struct, tag_value, tag_name, found=found, err_msg=err_msg
;
; Inputs :
;	struct - input structure
;	tag_value -  new value to give tag
;	tag_name - string tag name to change
;
; Opt. Inputs : None.
;
; Outputs     : None
;
; Keywords:
;	found - if tag was found in structure and changed, then found is set to 1
;	err_msg - error message. Blank if none
;;
; Common      : None.
;
; Restrictions: None.
;
; Side effects: None.
;
; Category    : Structure handling
;
; Prev. Hist. : None.
;
; Written     : Kim Tolbert, 26-Sep-2000
; Modifications:
; 30-Sep-2005, Kim.  Modified doc header
;
;-

pro change_tag_value, struct, tag_value, tag_name, found=found, err_msg=err_msg
;help,struct
error = 0
err_msg = ''
found = 0

if size(struct, /tname) ne 'STRUCT' then err_msg = 'No structure passed in to CHANGE_TAG_VALUE.'

if size(tag_name, /tname) ne 'STRING' then err_msg = 'TAG_NAME must be a string.'

if n_elements(tag_name) ne 1 then err_msg = 'Restricted to changing one tag value at a time.'

if err_msg ne '' then begin
	message, err_msg, /cont
	return
endif

tags = tag_names(struct) & ntags=n_elements(tags)

q = where(strupcase(tag_name) eq tags, count)

; if count is 1, then we found the tag in the top level of the structure.  Change its value.
if count eq 1 then begin
	index = q[0]
	if size(struct.(index), /tname) eq 'POINTER' then begin
		if ptr_valid(struct.(index)) then *struct.(index) = tag_value else struct.(index) = ptr_new(tag_value)
	endif else begin
		struct.(index) = tag_value
	endelse
	found = 1
	return
endif

; Otherwise, for any tags that are structures, recurse to find tag.
for i = 0,ntags-1 do begin
	if  size(struct.(i), /tname) eq 'STRUCT' then begin
		temp = struct.(i)
		change_tag_value, temp, tag_value, tag_name, found=found, err_msg=err_msg
		struct.(i) = temp
		if found then return
	endif
endfor

end