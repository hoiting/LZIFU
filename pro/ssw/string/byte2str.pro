;+                                                                                 
; Project     : VSO                                                                
;                                                                                  
; Name        : byte2str                                                           
;                                                                                  
; Purpose     : convert byte array into string array                               
;                                                                                  
; Category    : utility string                                                     
;                                                                                  
; Syntax      : IDL> output=byte2str(input,newline=newline)                        
;                                                                                  
; Inputs      : INPUT = input bytarr                                               
;                                                                                  
; Outputs     : OUTPUT = output strarr with each new index corresponding to newline
;                                                                                  
; Keywords    : NEWLINE = byte value at which to break new line [def=13b]]         
;                                                                                  
; History     : 12-Nov-2005, Zarro (L-3Com/GSFC) - written                         
;                                                                                  
; Contact     : DZARRO@SOLAR.STANFORD.EDU                                          
;-                                                                                 
                                                                                   
function byte2str,input,newline=newline,no_copy=no_copy,skip=skip                  
                                                                                   
if size(input,/tname) ne 'BYTE' then begin                                         
 pr_syntax,'output=byte2str(input,newline=newline)'                                
 return,''                                                                         
endif                                                                              
                                                                                   
if is_number(newline) then bspace=byte(newline) else bspace=13b                    
if is_number(skip) then bskip=skip else bskip=1                                    
chk=where(input eq bspace,count)                                                   
                                                                                   
if count eq 0 then return,input                                                    
                                                                                   
np=n_elements(input)                                                               
output=strarr(count+1)                                                             
                                                                                   
kstart=[0,chk+bskip]                                                               
kend=[chk-1,np-1]                                                                  
                                                                                   
for i=0,count do begin                                                             
 ks=kstart[i] & ke=kend[i]                                                         
 if ke gt ks then output[i]=string(input[ks:ke])                                   
endfor                                                                             
                                                                                   
return,output                                                                      
                                                                                   
end                                                                                
