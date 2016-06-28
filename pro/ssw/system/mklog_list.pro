;+
; Project     : HESSI
;                  
; Name        : MKLOG_LIST
;               
; Purpose     : define environmental for first valid listed argument 
;               
; Category    : system utility
;               
; Explanation : 
;               
; Syntax      : IDL> mklog_list,name,value1,value2....
;    
; Examples    : 
;
; Inputs      : NAME = environment variable to define
;               VALUE1 = first argument to check
;               VALUE2 = second argument to check
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : VERBOSE = print result
;             
; Restrictions: Probably works in Windows. Up to 10 arguments checked.
;               
; Side effects: Env NAME is defined to first found argument
;               
; History     : Version 1,  26-May-1999, Zarro (SM&A/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mklog_list,name,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,verbose=verbose

if (datatype(name) ne 'STR') then return

for i=0,n_params()-2 do begin
 s=execute('var=p'+trim(num2str(i)))
 if datatype(var) eq 'STR' then begin
  chk=loc_file(var,count=count)
  if count gt 0 then begin
   mklog,name,var,verbose=verbose 
   return
  endif
 endif
endfor

return & end



