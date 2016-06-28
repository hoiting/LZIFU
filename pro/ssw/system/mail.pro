pro mail, message, users=users, subj=subj, file=file, self=self, $
	no_defsubj=no_defsubj, delete=delete
;
;+
;NAME:
;	mail
;PURPOSE:
;	To send a mail message to yourself or a list of users
;CALLING SEQUENCE:
;	mail, message
;	mail, message, users='lemen,freeland'
;	mail, message, subj="Test"
;	mail, file=file, users=users, /self
;OPTIONAL INPUT:
;	message	- a string array of the message that is to
;		  be sent.  Either the "message" or the "file"
;		  parameter must be used.
;OPTIONAL KEYWORD INPUT:
;	users	- a string containing the users who should receive
;		  the message.  If it is undefined, it will send the
;		  message to yourself only (can be used as notification
;		  that a program is finished)
;	subj	- a string that should appear on the subject line.  It 
;		  cannot have the " character in the string
;	file	- the name of a file that should be sent to the users
;		  Either the "message" or the "file" parameter must
;		  be used.  File can be an array of file names.
;	self	- if set, send a copy to yourself also
;
;       no_defsubj - if set, use user supplied subject only
;
;RESTRICTIONS:
;	Only works on Unix machines right now
;HISTORY:
;	Written 21-Mar-92 by M.Morrison
;	24-Nov-92 (MDM) - Modified not to use the subject option when running
;			  on the SGI machine.
;	14-Dec-92 (MDM) - Modified to work on MIPS machines
;	18-Dec-92 (MDM) - Modified to have the file name in the subject on
;			  non-SGI machines.
;	17-Feb-94 (SLF) - add no_defsubj 
;       26-feb-95 (SLF) - make sure proper mail (Mail) is selected
;			  (seperate from .cshrc/path) - avoid pipe (very slow)
;			  if message is string array, make temporary file,
;			  and recurse with file option, remove file...
;        3-mar-95 (SLF) - use /nodefsubj when recursing
;	18-Apr-97 (MDM) - Replace "which" with "which -f"
;	 3-Nov-97 (MDM) - Allow subject option on SGI machines (undo Nov-92 mod)
;-
;
qdebug = 0
;
if ( (n_elements(message) eq 0) and (not keyword_set(file)) ) then begin
    print, 'MAIL: No input message or file name passed - no mail sent'
    return
end
;
if (n_elements(users) eq 0) then users0 = getenv('USER') else users0 = arr2str(users)	 ;make sure users list is a scalar string
if (keyword_set(self)) then users0 = users0 + ',' + getenv('USER')
;
if (n_elements(subj) eq 0) then subj = 'Message from IDL MAIL program'
subj_cmd = ' -s "' + subj + '" '
;;if (!version.os eq 'IRIX') then subj_cmd = ' '			;no subject
;
delete=keyword_set(delete)

; SLF avoid shell/path problems 
spawn,['which','-f','Mail'],mail_cmd,/noshell		; check Mail first
if n_elements(mail_cmd) gt 1 then $
   spawn,['which','-f','mail'],mail_cmd,/noshell		; now try mail

if n_elements(mail_cmd) gt 1 then begin
   message,/info,'Cannot find unix mail...'
   return
endif

if (keyword_set(file)) then begin
    for i=0,n_elements(file)-1 do begin
	if (file_exist(file(i))) then begin
	    ;;if (!version.os ne 'IRIX') and not keyword_set(no_defsubj) $
	    if  not keyword_set(no_defsubj) $
	       then subj_cmd = ' -s "IDL Mail Message.  File: ' + file(i) + '" '
	    cmd = mail_cmd + ' ' + subj_cmd + users0 + ' < ' + file(i)
	    spawn, cmd
	    wait, 1
            if delete then file_delete,file(i)            
	end else begin
	    print, 'MAIL: File - ', file(i), ' not found.  Not sent to ', users0
	end
    end
endif else begin				; slf - make file and recurse
;  recurse with file option
   filename=concat_dir(get_logenv('HOME'),'mail_' + $
      strtrim(abs(fix(systime(1))),2))
   file_append,filename,message
   mail, users=users, subj=subj, file=filename, self=self, $
	/no_defsubj, /delete
endelse

return
end
