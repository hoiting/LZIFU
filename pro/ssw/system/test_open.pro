;+
; Project     : HINODE/EIS
;
; Name        : TEST_OPEN
;
; Purpose     : Test open a file to determine existence and/or write access
;
; Inputs      : FILE  = file to test
;
; Keywords    : See TEST_OPEN2
;
; Version     : Written, 12-Nov-2006, Zarro (ADNET/GSFC) 
;               - uses better FILE_TEST 
;
; Contact     : dzarro@solar.stanford.edu
;-

function test_open,file,_extra=extra,err=err,write=write

forward_function file_test,file_dirname

err=''
if is_blank(file) then return,0b

;-- new way

if since_version('5.4') then begin

 chk=file_test(file)
 if (1-keyword_set(write)) then return,chk

;-- /write and file doesn't exist, then test if directory is writeable

 if chk then return,file_test(file,/write)

 fdir=file_dirname(file)
 return,file_test(fdir,/write)
endif

;-- old way

return,test_open2(file,_extra=extra,err=err,write=write)

end
