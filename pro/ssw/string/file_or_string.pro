;+
; Project     : SOHO - CDS
;
; Name        : FILE_OR_STRING
;
; Purpose     : check if a valid filename or string datatype is being input
;
; Category    : utility
;
; Explanation : useful when ASCII input to a program can come from an file
;               or a string variable
;
; Syntax      : IDL> file_or_string,file,string,err=err
;
; Example:    : send_printer,'test.doc',que='soho-laser1',qual='h'
;
; Inputs      : See keywords
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : ERR - error message (blank if no error found)
;               FILE = filename to check
;               STRING = string variable to check
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  4-Mar-1996,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro file_or_string,file=file,string=string,err=err

on_error,1
err=''

if (datatype(string) eq 'STR') and (datatype(file) eq 'STR') then begin
 err='Cannot simultaneously use file or string array as inputs'
 message,err,/cont
 return
endif

if (datatype(string) ne 'STR') and (datatype(file) ne 'STR') then begin
 err='Enter filename or string array'
 message,err,/cont
 return
endif

if datatype(file) eq 'STR' then begin
 chk=loc_file(file,count=count)
 if count eq 0 then begin
  err='Cannot locate '+file
  message,err,/cont
  return
 endif
endif

return & end

