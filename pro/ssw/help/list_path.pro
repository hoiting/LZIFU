;+
; Project     : SOHO - CDS
;
; Name        : LIST_PATH
;
; Category    : Help, Utility
;
; Purpose     : Manage listing of IDL path
;
; Explanation : Used in WWW version of XDOC
;
; Syntax      : IDL> list_path,file
;
; Inputs      : FILE = filename for output listing
;
; Opt. Inputs : None
;
; Outputs     : STDOUT listing of path (if FILE not entered)
;
; Opt. Outputs: None
;
; Keywords    : RESET = reset internal commons
;               HESSI = add HESSI path
;               BATSE = add BATSE path
;               SMM = add SMM path
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  1-Oct-1998,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

;--------------------------------------------------------------------------

pro rem_lib,tlibs,item

if exist(tlibs) and exist(item) then begin
 wpos=where( strpos(tlibs,item) eq -1,count)
 if count gt 0 then tlibs=tlibs(wpos)
endif

return & end

;--------------------------------------------------------------------------

pro list_path,file,libs=libs,status,reset=reset,hessi=hessi,batse=batse,smm=smm

common list_path_com,tlibs,tpath

;-- check last !path saved in common
 
status=''
new_path=1
hessi=keyword_set(hessi)
batse=keyword_set(batse)
smm=keyword_set(smm)
libs=''

if exist(tpath) then new_path=tpath ne !path

if not exist(tlibs) or keyword_set(reset) or new_path then begin
 dprint,'% print_path: getting path...'
 ssw=getenv('SSW')
 if hessi and (strpos(!path,'/hessi/idl') eq -1) then $
  !path=!path+':'+expand_path('+'+ssw+'/hessi/idl')
 if batse and (strpos(!path,'/cgro/batse/idl') eq -1) then $
  !path=!path+':'+expand_path('+'+ssw+'/cgro/batse/idl')
 if smm then $
  !path=!path+':'+expand_path('+'+ssw+'/smm')

 clean_path,/nosite,/noucon
 tlibs=get_lib(/no_current)
 tpath=!path
 rem_lib,tlibs,'/soho/wcat'
 rem_lib,tlibs,'/users/soho'
 rem_lib,tlibs,'/spartan'
 rem_lib,tlibs,'/soho/soho_maint'
 if not hessi then rem_lib,tlibs,'/hessi'
 if not smm then rem_lib,tlibs,'/smm'
 if not batse then rem_lib,tlibs,'/cgro'
endif

if exist(tlibs) then libs=tlibs else begin
 message,'Problems listing !path',/cont
 return
endelse

;-- write listing

if datatype(file) eq 'STR' then begin
 openw,lun,file,/get_lun
 if n_elements(tlibs) eq 1 then tlibs=[tlibs]
 printf,lun,transpose(tlibs)
 close,lun & free_lun,lun
 espawn,'chmod guo+w '+file
endif else begin
 print,transpose(tlibs)
endelse

status='1'
return & end

