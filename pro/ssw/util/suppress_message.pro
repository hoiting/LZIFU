;+
; Project     : SOHO - CDS
;
; Name        : SUPPRESS_MESSAGE
;
; Purpose     : check if a suppressed message is stored in COMMON 
;
; Category    : utility
;
; Explanation : useful for controlling display of messages in widget apps
;               such as XACK
;
; Syntax      : IDL> s=suppress_message(mess)
;
; Inputs      : MESS = message string (array or scalar)
;
; Opt. Inputs : None
;
; Outputs     : S = 1 if message is suppressed in COMMON, 0 otherwise
;
; Opt. Outputs: None
;
; Keywords    : /ADD - store message in COMMON
;               /REMOVE - remove message from COMMON
;               /CLEAR - clear all messages from COMMON
;
; Common      : SUPPRESS_MESSAGE
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  11-Sep-1996,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function suppress_message,mess,remove=remove,add=add,clear=clear

common suppress_message,supp_mess

if keyword_set(clear) then delvarx,supp_mess

if datatype(mess) ne 'STR' then return,0
smess=strlowcase(trim(str2lines(mess,/reverse)))

;-- add new message

if keyword_set(add) then begin
 if (datatype(supp_mess) ne 'STR') then $
  supp_mess=smess else supp_mess=[supp_mess,smess]
 return,0
endif

;-- check and/or remove message

if datatype(supp_mess) eq 'STR' then begin
 slook=where(smess eq supp_mess,scnt)
 if scnt gt 0 then begin
  if keyword_set(remove) then begin
   dlook=where(smess ne supp_mess,dcnt)
   if dcnt gt 0 then supp_mess=supp_mess(dlook) else delvarx,supp_mess
  endif else return,1
 endif
endif

return,0 & end

