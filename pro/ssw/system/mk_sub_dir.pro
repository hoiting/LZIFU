;+
; Project     : HESSI
;
; Name        : MK_SUB_DIR
;
; Purpose     : create subdirectories under parent
;
; Category    : utility system
;
; Syntax      : mk_sub_dir,parent,sub_dir
;
; Inputs      : PARENT = parent directory under which to create sub_dir
;               SUB_DIR = subdir names
;
; Keywords    : ERR= error string
;               OUT_DIR = created directory names
;               
; History     : Written, 22 March 2001, D. Zarro (EITI/GSFC)
;               Modified, 13 April 2004, Zarro (L-3Com/GSFC) - call MK_DIR
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mk_sub_dir,parent,sub_dir,err=err,out_dir=out_dir,_extra=extra

err=''
if is_blank(sub_dir) then return
if not test_dir(parent,err=err,out=pdir) then return
usub_dir=get_uniq(sub_dir)
out_dir=concat_dir(pdir,usub_dir)
mk_dir,out_dir,/g_write,/a_read,/u_write,_extra=extra
return
end
