;+
; Project     : HESSI
;                  
; Name        : MK_FILE
;               
; Purpose     : create an empty file
;                             
; Category    : system utility
;               
; Syntax      : IDL> mk_file,name
;    
; Inputs      : NAME = filename to create (with path, otherwise
;                      create in current directory)
;               
; Outputs     : None
;               
; Keywords    : None
;             
; History     : 18-Oct-2000, Zarro (EIT/GSFC), written
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro mk_file,file,err=err

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 goto,quit
endif

if not is_string(file) then return
break_file,file,dsk,dir,name
cdir=trim(dsk+dir)
if cdir eq '' then cdir=curdir()
if not test_dir(cdir,err=err) then return
openw,lun,file,/get_lun

quit:
if exist(lun) then free_lun,lun
chk=loc_file(file,count=count)
if (count eq 1) and (os_family(/lower) eq 'unix') then espawn,'chmod a+w '+file

return
end
