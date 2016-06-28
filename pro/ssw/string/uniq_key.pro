;+                                                                         
; Project     : HESSI                                                      
;                                                                          
; Name        : UNIQ_KEY                                                   
;                                                                          
; Purpose     : make _REF_EXTRA keywords unique                            
;                                                                          
; Category    : string system utility                                      
;                                                                          
; Syntax      : IDL> ref=uniq_key(keywords)                                
;                                                                          
; Inputs      : KEYWORDS = string array of keywords                        
;                                                                          
; Outputs     : REF = array with unique keywords                           
;                                                                          
; Keywords    : None                                                       
;                                                                          
; History     : Written, 18-May-2006 Zarro (L-3Com/GSFC)                   
;                                                                          
; Contact     : dzarro@solar.stanford.edu                                  
;-                                                                         
                                                                           
                                                                           
function uniq_key,keywords
                                                                           
if is_blank(keywords) then return,''                                       
                                                                           
np=n_elements(keywords)                                                    
if np eq 1 then return,keywords                                            
keys=strtrim(keywords,2)                                                       
                                                                           
;-- do a quick uniqueness test                                             
                                                                           
s=uniq(keys,sort(keys))                                                               
keys=keys[s]                                                               
np=n_elements(keys)                                                        
if np eq 1 then return,keys                                                
                                                                           
;-- examine each keyword. If keyword matches a substring of                
;   the other keywords in the list, then it is a duplicate and removed from
;   list                                                                   
                                                                           
ref=keys                                                                   
for i=0,np-1 do begin                                                      
 key=keys[i]                                                               
 chk=where(key ne ref,count)                                               
 if count gt 0 then begin                                                  
  skeys=ref[chk]                                                           
  chk=where(stregex(skeys,key) eq 0,count)                                
  if count gt 0 then ref=skeys                                             
 endif                                                                     
endfor                                                                     
                                                                           
return,ref                                                                 
end                                                                        
                                                                           
                                                                           
