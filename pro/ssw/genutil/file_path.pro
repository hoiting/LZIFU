function file_path, file, topdir, multiple=multiple
;+
; 
;   Name: file_path
;
;   Purpose: find file in tree (recursive version of RSI filepath.pro)
;
;   Input Parameters:
;      file   - file name to find
;      topdir - top directory for tree search  (default is $IDL_DIR)
;
;   Calling Sequence:
;      filename=file_path(file [,treetop])
;
;   Calling Examples:
;      colorfile=file_path('colors1.tbl')	; find file under $IDL_DIR
;
;   History:
;      23-jun-1995 (SLF) 
;-
if n_elements(topdir) eq 0 then topdir=get_logenv('$IDL_DIR')
subs=get_subdirs(topdir)
check=concat_dir(subs,file)			; possible file names
exist=file_exist(check)
yes=where(exist,count)

case count of
   0: retval=''
   1: retval=check(yes)
   else: if keyword_set(multi) then retval=check(yes) else $
            retval=check(yes(0))
endcase

return,retval
end

