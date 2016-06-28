;+
; Project     : Solar-B/EIS
;
; Name        : fix_path
;
; Purpose     : Fix IDL path names by expanding environment
;               variables and removing extraneous delimiters.
;
; Category    : utility string
;
; Syntax      : IDL> new=fix_path(path)
;
; Inputs      : PATH = IDL path name
;
; Outputs     : NEW  = fixed path name
;
; Keywords    : ERR = error string
;
; History     : 30-May-2006, Zarro (L-3Com/GSFC) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
                                                                                                                                                        
function fix_path,path,verbose=verbose                                                 
                                                                            
if is_blank(path) then return,''                                            
tpath=chklog(path,/pre)                                                     
tpath=str_replace(tpath,';',':')                                            
tdirs=str2arr(tpath,':')                                                    
delim=get_delim()                                                           
ndirs=n_elements(tdirs)                                                     
opath=''                                                                    

;-- loop thru each directory, filtering out blanks, duplicates, and
;   non-existent directories
                                                                               
for i=0,ndirs-1 do begin                                                    
  pdir=strtrim(tdirs[i],2)                                                  
  if is_blank(pdir) then begin
   if keyword_set(verbose) then message,'skipping blank directory',/cont
   continue                                           
  endif
  has_plus=stregex(pdir,'\+',/bool)                                         
  if has_plus then pdir=strmid(pdir,1,strlen(pdir))                         
  pdir=local_name(pdir,/no_expand)                                          
  pdir=str_trail(pdir,delim)                                                
  cdir=chklog(pdir,/pre)                                                    
  if cdir ne pdir then pdir=str_trail(pdir,delim)                           
  pdir=local_name(cdir,/no_expand)                                          
  if (1b-file_test(pdir,/dir)) then begin
   if keyword_set(verbose) then message,'Invalid directory - '+pdir,/cont
   continue                                 
  endif
  if has_plus then pdir='+'+pdir                                            
  if is_string(opath) then opath=opath+get_path_delim()+pdir else opath=pdir
endfor                                                                      
                                                                            
return,opath                                                                
                                                                            
end                                                                         
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            
