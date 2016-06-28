;+                                                               
; Project     : HESSI                                            
;                                                                
; Name        : FILE_COPY2                                       
;                                                                
; Purpose     : Wrapper around FILE_COPY that works for IDL < 5.6
;                                                                
; Category    : system utility                                   
;                                                                
; Syntax      : IDL> file_copy2,infile,outfile                   
;                                                                
; Inputs      : INFILE = input filenames to copy                 
;                                                                
; Outputs     : OUTFILE = output filenames                       
;                                                                
; Keywords    : See FILE_COPY                                    
;                                                                
; History     : 30 March 2006,  D.M. Zarro (L-3Com/GSFC)  Written
;                                                                
; Contact     : DZARRO@SOLAR.STANFORD.EDU                        
;-                                                               
                                                                 
pro file_copy2,infile,outfile,_ref_extra=extra,out=out           
                                                                 
out=''                                                           
if is_blank(infile) or is_blank(outfile) then return             
if n_elements(infile) ne n_elements(outfile) then return         
                                                                 
;-- use new version if available                                 
                                                                 
if since_version('5.6') then begin                               
 file_copy,infile,outfile,_extra=extra                           
 return                                                          
endif                                                            
                                                                 
;-- old way                                                      
                                                                 
if os_family() eq 'unix' then cmd='\cp' else cmd='copy'          
espawn,cmd+' '+infile+' '+outfile,out,/noshell                   
                                                                 
return & end                                                     
