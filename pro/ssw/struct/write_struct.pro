
;+
; Project     : RHESSI
;
; Name        : WRITE_STRUCT
;
; Purpose     : write structure tag values to a file
;
; Category    : structures
;
; Syntax      : IDL> write_struct,structure,file
;
; Inputs      : STRUCTURE = input structure to write
;             : FILE = filename to write to
;
; Outputs     : None
;
; Keywords    : Tag names of specific tag values to write 
;
; History     : 2-Jan-2005,  D.M. Zarro (L-3Com/GSFC)- Written
;               7-Mar-2008, Zarro (ADNET) 
;               - modified to support tags that are arrays,
;                 structures, or pointers
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
;----------------------------------------------------------------------------

pro write_struct_lun,structure,lun,_extra=extra

if ~is_struct(structure) then return
tags=tag_names(structure)
ntags=n_elements(tags)

if is_struct(extra) then wtags=tag_names(extra)

for i=0,ntags-1 do begin
 if exist(wtags) then begin
  chk=where(tags[i] eq wtags,count)
  if count eq 0 then continue
 endif
 val=(structure.(i))
 if size(val,/tname) eq 'POINTER' then begin
  if exist(*val) then val=*val else continue
 endif
 if is_struct(val) then write_struct_lun,val,lun,_extra=extra else $
  printf,lun,tags[i],' ',val
endfor

return & end

;-----------------------------------------------------------

pro write_struct,structure,file,_extra=extra

if ~is_struct(structure) or is_blank(file) then begin
 pr_syntax,'write_struct,structure,file'
 return
endif

;-- check for write access

path=file_dirname(file)
if is_blank(path) then path=curdir()
if ~file_test(path,/dir,/write) then begin
 message,'No write access to '+path,/cont
 return
endif

;-- open output file

openw,lun,file,/get_lun,error=error
if error ne 0 then return

;-- cycle thru structure tags

write_struct_lun,structure,lun,_extra=extra 
free_lun,lun

;-- clean up

if file_test(file,/zero) then begin
 message,'No matching tag names found',/cont
 file_delete,file,/quiet
endif

return
end
