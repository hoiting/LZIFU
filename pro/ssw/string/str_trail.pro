;+                                                                               
; Project     : HESSI                                                            
;                                                                                
; Name        : STR_TRAIL                                                        
;                                                                                
; Purpose     : remove a trailing item from a string                             
;                                                                                
; Category    : system utility string                                            
;                                                                                
; Syntax      : IDL> out=str_trail(value,item)                                   
;                                                                                
; Inputs      : VALUE = string value (can be array)
;               ITEM  = end item to remove 
;                       (can be array, e.g. ['/','@'])              
;                                                                                
; Outputs     : OUT = trimmed string [e.g. pub]                                  
;                                                                                
; Keywords    : COUNT = matching count                                           
;               MATCHING = strings                                               
;                                                                                
; History     : Written, 6-March-2000, Zarro (SM&A/GSFC)                         
;               Modified, 30-May-2006, Zarro (L-3Com/GSFC) 
;                - vectorized          
;               Modified, 3 March 2007, Zarro (ADNET)
;                - fixed STREGEX bug
;                                                                                
; Contact     : dzarro@solar.stanford.edu                                        
;-                                                                               
                                                                                 
function str_trail,value,item,count=count,match=match                            
                                                                                 
count=0                                                                          
match=''                                                                         
if is_blank(value) then return,''                                                
if is_blank(item) then return,value
pitem=strtrim(item,2)                                              
if n_elements(pitem) gt 1 then pitem='('+arr2str(pitem,delim='|')+')'                             
                                                                                 
pvalue=strtrim(value,2)                                                          
                                                                                 
chk=stregex(pvalue,'(.*)'+pitem+'$',/ext,/sub)                                   

match=where(chk[1,*] ne '',count)                                                
                                                                                 
if count eq 0 then return,value                                                  
out=value                                                                        
out[match]=chk[1,match]                                                          
if n_elements(out) eq 1 then out=out[0] else out=reform(out)                     
return,out                                                                       
                                                                                 
end                                                                              
                                                                                 
