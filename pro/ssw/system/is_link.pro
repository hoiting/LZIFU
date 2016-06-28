;+
; Project     : SOHO - CDS
;
; Name        : IS_LINK
;
; Purpose     : check if file name is actually a link
;
; Category    : Help system
;
; Explanation : spawns  'ls -l' to check for links
;
; Syntax      : IDL> link = is_link(file,out=out)
;
; Inputs      : FILE = string file name
;
; Opt. Inputs : None
;
; Outputs     : link = 1/0 if link or not
;
; Opt. Outputs: None
;
; Keywords    : OUT = translated file name
;
; Restrictions: UNIX only
;
; History     : Written, 22-March-2000,  D.M. Zarro (SM&A)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function is_link,file,out_file=out_file

out_file=''

if (os_family() ne 'unix') or (not exist(file)) or $
   (datatype(file) ne 'STR') or (is_dir(file)) then return,0b

if n_elements(file) ne 1 then begin
 message,'single filenames only',/cont
 return,0b
endif

count=0
espawn,'\ls -l '+file,out
arrows=strpos(out,'->')
links=where(arrows gt -1,count)
if count gt 0 then begin
 out=out(links) & arrows=arrows(links)
 lfile=strarr(count)
 for i=0,count-1 do lfile(i)=strmid(out(i),arrows(i)+2,strlen(out(i)))
 lfile=trim(lfile)
 if n_elements(lfile) eq 1 then lfile=lfile(0)
 out_file=lfile
endif

return,count gt 0

end


