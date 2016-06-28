;+
; Project     : SOHO - CDS     
;                   
; Name        : N_DIMENSIONS()
;               
; Purpose     : Returns number of dimensions of a variable.  
;               
; Explanation : Returns number of dimensions of a variable.  
;               cf. n_elements etc.
;
; Use         : n = n_dimensions(data)
;    
; Inputs      : data - variable to be investigated.
;               
; Opt. Inputs : None
;               
; Outputs     : Function value returns number of dimensions.
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, Numerical
;               
; Prev. Hist. : Idea by Stein Vidar Haugan.
;
; Written     : C D Pike, RAL, 13-Jan-94
;               
; Modified    : 
;
; Version     : Version 1, 13-Jan-94
;-            
function n_dimensions,data

return,(size(data))(0)

end
