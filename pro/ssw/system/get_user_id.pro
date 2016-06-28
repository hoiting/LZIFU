;+
; Project     : SOHO - CDS     
;                   
; Name        : GET_USER_ID
;               
; Purpose     : return user name and host 
;               
; Category    : utility
;               
; Explanation : 
;               
; Syntax      : IDL> user_id=get_user_id()
;
; Inputs      : None
;               
; Outputs     : USER_ID, e.g. zarro@smmdac.nascom.nasa.gov
;               
; History     : Version 1,  17-Aug-1996,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

function get_user_id,dummy

common get_user_id,last

os=os_family(/lower)
if os eq 'windows' then return,'anonymous@unknown'

if exist(last) then return,last

if os eq 'vms' then begin
 espawn, 'write sys$output f$getjpi(f$pid(pid), "username")',username
 user_id = trim(username) + '@' + getenv('UCX$INET_HOST')
endif else begin
 espawn, 'hostname', hostname,/noshell
 hostname=trim(hostname(0))
 if hostname eq '' then hostname='unknown'
 username=trim(chklog('LOGNAME'))
 if username eq '' then username='anonymous'
 user_id = username+ '@' + hostname
endelse

last=trim(user_id(0))
return,last
end

