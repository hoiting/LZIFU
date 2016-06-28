;+
; Project     : Solar-B/EIS
;
; Name        : expand_dirs
;
; Purpose     : Expand directory names below input directory
;
; Example     : IDL> dir=expand_dirs('+$SSW/gen')
;
;               Can have multiple directories separated by ':'
;               This function essentially replaces 'find_all_dir'
;
; Category    : utility string
;
; Syntax      : IDL> out=expand_dirs(dirs)
;
; Inputs      : DIRS = top directory to expand
;
; Outputs     : ODIRS  = array of top directory with subdirectories 
;
; Keywords    : PLUS_REQUIRED - if set, a '+' is required to force
;               expansion.
;               PATH_FORMAT - if set, expanded directories is returned
;               as a delimited string
;
; History     : 30-May-2006, Zarro (L-3Com/GSFC) - written
;               22-Aug-2006, Zarro (ADNET/GSFC) - added FIFO common
;               22-Jan-2007, Zarro (ADNET/GSFC) 
;                 - check that input dir is an environment variable
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
                                                                                         
function expand_dirs,dirs,plus_required=plus_required,reset=reset,path_format=path_format,_extra=extra

if is_blank(dirs) then return,''                                                         

cdirs=chklog(strtrim(dirs[0],2),/pre)
plus_required=keyword_set(plus_required)                                                 
path_delim=get_path_delim()                                                              
sdirs=cdirs+'_'+trim(plus_required)

;-- check last result

common expand_dirs,fifo

if obj_valid(fifo) and (1-keyword_set(reset)) then begin
 fifo->get,sdirs,fdirs
 if is_string(fdirs) then begin
  if keyword_set(path_format) then fdirs=arr2str(fdirs,path_delim)
  return,fdirs
 endif
endif

;-- loop thru each directory, filtering out blanks, duplicates, and
;   non-existent directories

tdirs=strtrim(str2arr(dirs,path_delim),2)
ndirs=n_elements(tdirs)                                                                  
for i=0,ndirs-1 do begin                                                                 
 pdir=tdirs[i]                                                                  
 has_plus=strpos(pdir,'+') eq 0
 if has_plus then vdir=strmid(pdir,1,strlen(pdir)) else vdir=pdir
 vdir=chklog(vdir,/pre)
 if has_plus then vdir='+'+vdir
 vdirs=str2arr(vdir,path_delim)
 save_dirs=''
 for k=0,n_elements(vdirs)-1 do begin
  pdir=vdirs[k]                                                                  
  has_plus=strpos(pdir,'+') eq 0
  if has_plus then vdir=strmid(pdir,1,strlen(pdir)) else vdir=pdir
  if is_dir2(vdir) then begin
   chk=where(vdir eq save_dirs,count)
   if count eq 0 then begin
    if (1-has_plus) and (1-plus_required) then pdir='+'+pdir                           
    edirs=expand_path(pdir,/all,/array)                                                    
    if not exist(odirs) then odirs=temporary(edirs) else $
     odirs=[temporary(odirs),temporary(edirs)]
    save_dirs=[save_dirs,vdir] 
   endif
  endif
  
 endfor
endfor                                                                                   
odirs=get_uniq(odirs)

;-- save result

if not obj_valid(fifo) then fifo=obj_new('fifo')

if is_string(odirs) then begin
 fifo->set,sdirs,odirs
 if keyword_set(path_format) then odirs=arr2str(odirs,path_delim)                         
endif else odirs=''

return,odirs                                                                             
                                                                                         
end                                                                                      
                                                                                         
                                                                                         
                                                                                         
