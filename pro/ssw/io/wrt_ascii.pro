;+
; Project     : SOHO - CDS
;
; Name        : WRT_ASCII
;
; Purpose     : Writes a string array to an ascii file
;
; Explanation : Uses simple PRINTF to write named string (array) to named
;               file.
;
; Use         : IDL> wrt_ascii, array, file
;
; Inputs      : array - string (array) to write
;               file  - name of file to write.  Written to current directory
;                       unless path given also.
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; Category    : Data, i/o
;
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 4-Oct-96
;
; Modified    : Added format spec to printf.  CDP, 17-Jan-97
; Modified:		31-Jul-2000, Kim Tolbert, added err_msg keyword
;
; Version     : Version 2, 17-Jan-97
;-

pro wrt_ascii, text, file, err_msg=err_msg

err_msg = ''

;
;  check input
;
if n_params() lt 2 then begin
   print,'Use:  IDL> wrt_ascii, text, file
   return
endif

;
;  get max length of entries (printf does helpful things on arrays with
;  non-equal length members)
;

nmax = max(strlen(text))

;
;  open and write to file
;
openw,lun,file,/get_lun,error=err
if err ne 0 then begin
   print,'Error opening file '+file
   err_msg = !err_string
   return
endif

;
;  output data and tidy up
;
printf,lun,strpad(text,nmax,/after),format='(a)'
close,lun
free_lun,lun

end
