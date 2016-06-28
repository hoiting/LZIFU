;+
; Project     : RHESSI
;                   
; Name        : IN_RANGE
;               
; Purpose     : check if all input data values are with a selected data range
;               
; Category    : utility
;               
; Syntax      : IDL> out=in_range(input,array)
;    
; Inputs      : INPUT = array of values to check
;               ARRAY = target array of values
;               
; Outputs     : 1 - if at all input points inside array ranges
;               0 - if at least one point is outside
;
; History     : 8-Oct-02, Zarro (LAC/GSFC) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-      


function in_range,input,array

if (not exist(input)) or (not exist(array)) then return,0b
np=n_elements(input)
amax=max(array,min=amin)
imax=max(input,min=imin)

out=(imin lt amin) or (imax gt amax)

return,1b-out
      
end
