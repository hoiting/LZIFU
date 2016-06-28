pro restore_idl_routines, pattern=pattern, status=status, $
    loud=loud,  date=date, nodate=nodate,  _extra=_extra
;+
;
;   Name: restore_idl_routines
;
;   Purpose: restore IDL binary routine files written via save_idl_routines
;
;   Input Parameters:
;      NONE
; 
;   Keyword Parameters:
;      pattern - desired pattern to restore 
;               (assumed same pattern as used in save_idl_routine.pro call)
;      status - boolean success (0 implies file not found)
;      loud - if set, be more verbose
;      _extra - other keyword passed to 'restore'
;
;   History:
;      19-October-1999 - S.L.Freeland - Written
;
;-

loud=keyword_set(loud)
status=0
; get the filename for this set of keywords
save_idl_routines, /name_only, file=file, pattern=pattern, $
    nodate=nodate, date=date

file=last_nelem(file)

if not file_exist(file(0)) then begin 
   box_message,'Routine save file: ' + file(0) +  ' not found.., returning'
   return
endif

if loud then box_message,['-- Restoring routines from file --',file],/center
restore, file, _extra=_extra

return
end
