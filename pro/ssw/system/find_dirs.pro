;+
; Project     : Solar-B/EIS
;
; Name        : find_dirs
;
; Purpose     : Expand directory names below input directory.
;               Same as find_all_dirs but without spawning or recursion.
;
; Example     : IDL> dir=find_dirs('+$SSW/gen')
;
; Category    : utility string
;
; Syntax      : IDL> out=find_dirs(dir)
;
; Inputs      : DIR = top directory to expand
;
; Outputs     : ODIRS  = array of top directory with subdirectories
;
; Keywords    : FOLLOW_SYMLINK - set to follow symbolic links
;
; History     : 21-Feb-2008, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function find_dirs,dir,count=count,follow_symlink=follow_symlink,$
                       _extra=extra,verbose=verbose

count=0l
if n_elements(dir) eq 0 then return,''
unix=os_family(/lower) eq 'unix'

;-- check for plus

tdir=chklog(strtrim(dir,2),/pre)

has_plus=stregex(tdir,'^\+',/bool)
if has_plus then tdir=strmid(tdir,1,strlen(tdir))

;-- return if not a readable directory

if ~file_test(tdir,/directory,/read) then return,''

sep=path_sep() & wild='*'
output=file_search(tdir+sep+wild,/test_dir,/test_read,/match_initial_dot,_extra=extra,count=count)
if count eq 0 then return,''

;-- done if not recursing

if ~has_plus then return,output

follow_links=keyword_set(follow_symlink)
i=-1
repeat begin
 i=i+1
 tdir=output[i]
 if keyword_set(verbose) then print,i,tdir
 if unix then begin
  if ~follow_links then begin
   is_link=file_test(tdir,/symlink)
   if is_link then continue
  endif
 endif
 noutput=file_search(tdir+sep+wild,/test_dir,/test_read,/match_initial_dot,_extra=extra,count=tcount)

 if tcount gt 0 then begin
  output=[temporary(output),temporary(noutput)]
  count=count+tcount
 endif
endrep until (i eq (count-1))

count=n_elements(output)
if count eq 1 then output=output[0]
return,output

end





