;+
; Project     : SOHO - CDS     
;                   
; Name        : NDIM_INDICES()
;               
; Purpose     : Return n-dimensional indices from a one-dimensional index
;               
; Explanation : WHERE() returns a one-dimensional index - this routine
;               converts that index into N indices pointing to the same
;               element of an N-dimensional block. To do this, both the
;               one-dimensional index and the N-dimensional data block must be
;               supplied.
;               
; Use         : indices=get_indices(data,index)
;    
; Inputs      : DATA : The N-dimensional data block.
;
;               INDEX : The one-dimensional index.
; 
; Opt. Inputs : None
;               
; Outputs     : Returns n-dimensional indices as a LONG array.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: ..
;               
; Side effects: None.
;               
; Category    : Array utility
;               
; Prev. Hist. : None.
;
; Written     : SVH Haugan, UiO, 15 September 1997
;               
; Modified    : Version 1, SVHH, 15 January 1999
;                       Renamed from GET_INDICES() to avoid conflict
;                       with Yohkoh routine by the same name.
;
; Version     : 1, 15 January 1999
;-            

FUNCTION ndim_indices,data,linear_index
  
  szd = size(data)
  
  indices = lonarr(szd(0))
  
  ixi = linear_index
  
  FOR i = 1,szd(0) DO BEGIN
     indices(i-1) = ixi MOD szd(i) & ixi = ixi / szd(i)
  END
  
  return,indices
  
END

  
  
