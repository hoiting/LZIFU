;+
; Project     :	SDAC
;
; Name        :	CHK_STRUCT_NAME
;
; Purpose     :	check if a structure name is unique
;
; Explanation :	
;
; Use         : STATUS=CHK_STRUCT_NAME(SNAME)
;
; Inputs      :	SNAME = structure name to check
;
; Opt. Inputs :	None.
;
; Outputs     :	STATUS =0/1 if SNAME already exists/doesn't exist
;
; Opt. Outputs:	None.
;
; Keywords    :	TEMPLATE = extant structure with name SNAME
;             : VERBOSE = for messages
;
; Calls       :	EXECUTE
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Structure handling
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 7 July 1995
;-

function chk_struct_name,sname,template=template,verbose=verbose

on_error,1

verbose=keyword_set(verbose)
if datatype(sname) ne 'STR' then begin
 message,'input must be non-blank string',/cont
 return,0
endif

;-- anonymous names are always unique

if strtrim(sname,2) eq '' then return,1

template=0
error=0 & try=1
catch,error
if error ne 0 then try=0

if try then begin
 status=execute('template={'+sname+'}')
 status=1-status
endif else status=1

if not status then begin
 if verbose then message,'Structure type already defined: '+sname,/cont
endif else begin
 if verbose then message,'OK to use: '+sname,/cont
endelse

return,status & end


