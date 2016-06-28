;+
; Project     : SOHO - CDS
;
; Name        : SEND_MAIL
;
; Purpose     : to e-mail a file or array 
;
; Category    : Device
;
; Explanation : checks operating system and spawns the appropriate
;               command.
;
; Syntax      : IDL> send_mail,file,address,array=array
;
;
; Inputs      : FILE = filename to mail
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : ERR - error message
;               ADDRESS = address to send to (e.g., zarro@smmdac)
;               ARRAY - alternative string array to print
;
; Common      : None
;
; Restrictions: None
;
; Side effects: File deleted when /DEL set
;
; History     : Version 1,  4-Sep-1995,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro send_mail,file,err=err,array=array,address=address

on_error,1
err='' 

;-- check inputs

if datatype(address) ne 'STR' then begin
 err='Enter full name and address (e.g. zarro@smmdac)'
 message,err,/cont
 return
endif

file_or_string,file=file,string=array,err=err
if err ne '' then return

;-- send array or file

del=0
if datatype(array) eq 'STR' then begin
 del=1
 str2file,array,temp
endif else temp=file

;-- spawn mail

if os_family() eq 'vms' then cmd='mail '+temp+' '+'smtp%"""'+address+'"""' else $
 cmd='mail '+address+' < '+temp

espawn,cmd,out

if out(0) ne '' then begin
 err=out(0)
 message,err,/cont
endif

;-- delete temporary file

if del then rm_file,temp

return & end


