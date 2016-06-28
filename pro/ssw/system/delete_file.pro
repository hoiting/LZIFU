;+
; Project     : SOHO - CDS     
;                   
; Name        : DELETE_FILE()
;               
; Purpose     : Delete a named file.
;               
; Explanation : Spawn the OS appropriate delete command.
;               
; Use         : IDL> status = delete_file(filename [,report=report])
;    
; Inputs      : filename   - file to be deleted, must include path
;               
; Opt. Inputs : None
;               
; Outputs     : Function value = 1 for success = 0 for failure
;               
; Opt. Outputs: Report   -  the os response to the delete command
;               
; Keywords    : NOCONFIRM  - suppress any delete confirmation requests
;
; Calls       : None
;               
; Restrictions: VMS and Unix only
;               
; Side effects: None
;               
; Category    : Util, Operating_system
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 13-May-93
;               
; Modified    : Added NOCONFIRM keyword.  CDP, 26-Apr-95
;
; Version     : Version 2, 26-Apr-95
;-            

function delete_file, in_file, report=report, noconfirm=noconfirm

;
;  check have file name
;
if n_params() lt 1 then begin
   bell
   print,'Use: delete_file, file_name'
   return,0
endif

;
;  set up command according to OS
;
if !version.os eq 'vms' then begin
   if not keyword_set(noconfirm) then begin
      com = 'delete '+in_file+';*'
   endif else begin
      com = 'delete/noconfirm '+in_file+';*'
   endelse
endif else begin
   if not keyword_set(noconfirm) then begin
      com = 'rm '+in_file
   endif else begin
      com = 'rm -f '+in_file
   endelse
endelse

;
;  doooo it
;
spawn,com,report

;
;  check if any (error) message back
;
if !version.os eq 'vms' then begin
   status = strpos(report(0),'DELETE') lt 0
endif else begin
   status = strpos(report(0),'rm:') lt 0
endelse

return, status

end
