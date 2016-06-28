;+
; Project     : Hinode/EIS
;
; Name        : load_external
;
; Purpose     : Load platform/OS appropriate shareable object
;
; Category    : utility system
;
; Syntax      : IDL> load_external
;
; Inputs      : None
;
; Outputs     : None (though SSW_EXTERNAL_F is redefined)
;
; Keywords    : VERBOSE
;
; History     : Written, 14-Feb-2007, Zarro (ADNET)
;-

pro load_external,verbose=verbose

verbose=keyword_set(verbose)
sbin=local_name('$SSW_BIN')
if is_dir(sbin) then mklog,'SSW_BIN',sbin
share_obj=ssw_bin('external.so')
share_obj=share_obj[0]
if file_test(share_obj) then begin
 mklog,'SSW_EXTERNAL_F',share_obj
 if verbose then message,'Setting SSW_EXTERNAL_F = '+share_obj,/cont
endif
return & end
