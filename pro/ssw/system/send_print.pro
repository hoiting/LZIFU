;+
; Project     : SOHO - CDS
;
; Name        : SEND_PRINT
;
; Purpose     : to print a file or array in a device independent way
;
; Category    : Device
;
; Explanation : checks operating system and spawns the appropriate
;               command.
;
; Syntax      : IDL> send_print,file,queue=queue,qual=qual,array=array
;
; Example:    : send_print,'test.doc',queue='soho-laser1',qualifier='h'
;
; Inputs      : FILE = filename to print
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : QUEUE	  = Printer queue name [default = '']
;               QUALIFIER = Qualifier to the print statement [default = '']
;               DELETE	  = Set to delete file when done.
;               ERR	  = Error message.
;               ARRAY	  = Alternative string array to print
;               DEVICE    = set to use DEVICE,/CLOSE for .ps files
;
; Common      : None
;
; Restrictions: Print queues must exist
;
; Side effects: File deleted when /DELETE set
;
; History     : Version 1,  4-Sep-1995,  D.M. Zarro.  Written
;		Version 2, 17-May-1996, William Thompson, GSFC
;			Changed QUE and QUAL keywords to their full names.  The
;			abbreviations can still be used
;               Modified, 1-May-2000, Zarro (SM&A/GSFC) - added check
;                       for Postscript file
;			1-Aug-2000, Kim Tolbert.  Didn't quite work for Windows OS.
;				For Windows, use 'copy /b filename queue' command.  If queue not
;				passed in, use PSLASER env var.
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro send_print,file,queue=queue,qualifier=qualifier,delete=delete,$
               err=err,array=array

on_error,1
err=''

;-- check inputs

file_or_string,file=file,string=array,err=err
if err ne '' then return

;-- print array or file

if datatype(array) eq 'STR' then begin
 delete=1
 str2file,array,temp
endif else begin
 if is_open(file,unit=unit) then begin
  message,'closing "'+file+'"',/cont
  if is_ps(file) then begin
   dsave=!d.name & set_plot,'ps' & device,/close & set_plot,dsave
  endif else close,unit
 endif
 temp=file
 delete=keyword_set(delete)
endelse

;-- check for print command as environment variable

os=os_family()
vms=(os eq 'vms')
windows =  (os eq 'Windows')
unix = not (vms or windows)

printcom=chklog('PRINTCOM')
if printcom eq '' then printcom=chklog('IDL_PRINT_TEXT')
if printcom eq '' then begin
 if vms then printcom='print' else printcom='lpr'
 if windows then printcom = 'copy /b'
endif

;-- take care of qualifiers and queues
;   usually qualifiers are preceded by '-' in Unix and '/' in VMS
;   usually print queues are specified by '-P' in Unix and '/queue=' in VMS

if datatype(qualifier) ne 'STR' then qualifier=''
if datatype(queue) ne 'STR' then queue='' else queue=trim(queue)

if vms then begin
 if qualifier ne '' then begin
  chk=strpos(qualifier,'/')
  if chk eq -1 then aqualifier='/'+qualifier else aqualifier=qualifier
 endif else aqualifier=' '
 if queue ne '' then aqueue='/queue='+queue else aqueue=' '
 com=printcom+' '+aqualifier+' '+aqueue+' '+temp
 ;-- for remote printing
 dc=strpos(temp,'::')
 if (dc gt -1) then com=com+' /remote'
endif

if unix then begin
 if qualifier ne '' then begin
  chk=strpos(qualifier,'-')
  if chk eq -1 then aqualifier='-'+qualifier else aqualifier=qualifier
 endif else aqualifier=' '
 if (queue ne '') and (queue ne 'lpr')  then aqueue='-P '+queue else aqueue=' '
 com=printcom+' '+aqualifier+' '+aqueue+' '+temp
endif

if windows then begin
 if queue eq '' or strlowcase(queue) eq 'pslaser' then queue = getenv ('PSLASER')
 if queue eq '' then begin
 	message, 'Logical name PSLASER or keyword queue must be defined.'
 	return
 endif
 com = printcom + ' ' + temp + ' ' + queue
 print, 'print command = ', com
endif

espawn,com,out

if out(0) ne '' then begin
 err=out(0)
 message,err,/cont
endif

;-- delete file if requested

if delete then begin
 dprint,'% SEND_PRINT: deleting print file'
 rm_file,temp
endif

return & end


