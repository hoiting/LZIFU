function password_info, pattern,  _extra=_extra 
;   user=user, password=password, uid=uid, gid=gid, who=who, home=home, shell=shell
;+
;   Name: password_info
;
;   Purpose: read/parse password file  - optionlly match user PATTERN
;
;   History:
;      23-Sep-1999 - S.L.Freeland - sytem management and ssw maint
;
;   Input Parameters:
;       pattern - optional string pattern to match
; 
;   Output Parameters:
;      extracted field from passwd file, value depends on keyword
;
;   Keyword  Parameters:
;      /user, /password, /uid, /gid, /who, /home, /shell
;      (mutually exclusive switches determine output)
;  
;   Calling Sequence:
;      table=password_info( ['PATTERN'])            ; strarr(7,nusers)
;      field=password_info( ['PATTERN' ] /FIELD)    ; 
;  
;   Calling Examples:
;     users=password_info(/user)               ; return all users in pwf
;     home=password_info(users(n),/home)       ; $HOME for user=users(n)
;     IDL> if password_info('ftp',/home) eq '' then $
              message,'No anonymous ftp on this machine...'
;
;     IDL> help,password_info()                      ; no switch? -> all info
;          <Expression>    STRING    = Array[7, 26]  ; 

;     IDL> help,password_info(get_user())            ; no switch w/pattern?
;          <Expression>    STRING    = Array[7]      ; matching info
;-
;
if os_family()  ne 'unix' then begin 
   box_message,'Sorry, UNIX only for now...'
   return,''
endif

pwf='/etc/passwd'

if not file_exist(pwf) then begin 
   box_mesage,'Password file: ' + pwf + ' not found...'
   return,''
endif

pwdata=rd_tfile(pwf,nocomment='#')       ; read/decomment (rd_tfile.pro)

; ------- optionally take record subset matching user input pattern ---------
if data_chk(pattern,/string) then begin
   patt=str_replace(pattern(0),'*','')
   ss=wc_where(pwdata,'*'+patt+'*',/case_ignore, count)    
   if count eq 0 then begin 
      box_message,'No password records matching pattern: ' + '*'+patt+'*'
      return,''
   endif 
   pwdata=pwdata(ss)   
endif
; ----------------------------------------------------------------

pwtable=str2cols(pwdata,':',/unaligned)     ; parse it (str2cols.pro)
strtab2vect,pwtable, userx, pwx, uidx, gidx, whox, homex, shellx  ; 2D->1D

retval=pwtable

if data_chk(_extra,/struct) then begin 
   field=strlowcase ((tag_names(_extra))(0))   ; /XXX->field
   estat=execute('retval='+field+'x')          ; map xxx->1D
endif

return,retval
end
