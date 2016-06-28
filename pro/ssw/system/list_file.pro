;+
; Project     : EIS
;
; Name        : LIST_FILE
;
; Purpose     : fast file listing
;
; Category    : utility system
;
; Syntax      : IDL> files=list_files(dir,filter=filter)
;
; Inputs      : DIR = directory to search
;
; Outputs     : FILES = files in PATH
;
; Keywords    : COUNT = # of files found
;               FILTER = file filter (e.g. '*.*')
;
; History     : Written, 11 June 2004, D. Zarro (L-3Com/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function list_file,dir,filter=filter,count=count,err=err

err=''
count=0
if n_params() eq 0 then cd,current=odir else begin
 if not is_dir(dir,out=odir,err=err,/expand) then begin
  message,err,/cont
  return,''
 endif
endelse

windows=os_family(/lower) eq 'windows'
cd,current=current
cd,odir
if windows then results=findfile('*.*',count=count) else $
 espawn,'\ls -F ',results,count=count,/noshell
cd,current

if count eq 0 then return,''
results=odir+get_delim()+temporary(results)

dirs=where2(stregex(results,'(\\|\/)$',/bool),complement=chk,ncomplement=count)
if count eq 0 then return,''
if n_elements(results) ne n_elements(chk) then results=results[chk]
if not windows then results=str_trail(results,'(\@|\*|\|\=)')

if is_string(filter) then begin
 sf=str_replace(filter,'.','\.')
 sf=str_replace(sf,',',' ')
 sf=strcompress(sf)
 sf=str_replace(sf,'*','.+')
 sf=str_replace(sf,' ','|')
 sf=strcompress(sf,/remove)
endif
 
if is_string(sf) then begin
 dprint,'% STREGEX: ',sf
 if (sf ne '.+') then begin
  chk=where(stregex(results,sf,/bool),count)
  if count eq 0 then return,''
  if count ne n_elements(results) then results=results[chk]
 endif
endif

if count eq 0 then results=results[0]
return,results
end

