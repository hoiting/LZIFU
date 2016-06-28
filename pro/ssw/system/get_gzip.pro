;+
; Project     : HESSI
;
; Name        : GET_GZIP
;
; Purpose     : find GZIP command on a Windows system
;
; Category    : system, utility,i/o
;
; Syntax      : gzip_cmd=get_gzip()
;
; Inputs      : None
; 
; Keywords    : ERR = error string
;
; Restrictions: Windows only
;
; History     : May 20 Apr 2000, D. Zarro (SMA/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

 function get_gzip,err=err

 err=''

;-- check if user has local GZIP stored in env, else use one from SSW

 if os_family(/lower) ne 'windows' then begin
  err='Windows only'
  message,err,/cont
  return,''
 endif

 gzip_cmd=''
 zip_cmd=chklog('gzip_cmd')
 if zip_cmd eq '' then zip_cmd='$SSW\packages\binaries\exe\Win32_x86\GZIP.EXE'
 chk=loc_file(zip_cmd,count=count)
 if count ne 0 then gzip_cmd=chk(0)

;-- still none? Check for local copy

 if gzip_cmd eq '' then begin
  have_gzip=have_proc('gzip_exe.pro',out=gzip_cmd)
  if have_gzip then begin
   temp_dir=get_temp_dir()
   lgzip=temp_dir+'\gzip.exe'
   chk=loc_file(lgzip,count=count)
   if count eq 0 then begin
    state='copy '+gzip_cmd+' '+lgzip
    dprint,'% GET_GZIP: ',state
    espawn,state,/noerror
   endif
   gzip_cmd=lgzip
  endif
 endif

 if gzip_cmd eq '' then begin  
  err='cannot locate Windows gunzip command'
  message,err,/cont
 endif

 return,gzip_cmd
 
 end


