;+
; Project     : HINODE/EIS
;
; Name        : FIX_DIR_NAME
;
; Purpose     : Fix directory name
;
; Example     :
;
;             IDL> f='/Users/zarro/.decompressed/..'
;             IDL> print,fix_dir_name(f)
;                  /Users/zarro
;
; Inputs      : DIR  = directory name to fix
;
; Outputs     : OUT = fixed directory name
;
; Keywords    : ERR = string error message
;
; Version     : Written 4-Dec-2006, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function fix_dir_name,dir,err=err

err=''
if is_blank(dir) then return,''
cd,curr=curr

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 cd,curr
 err='Non-existent or unreadable directory => '+dir
 return,''
endif

in=chklog(dir,/pre)
cd,in
cd,curr,curr=out

return,out

end
