;+
; Project     : SOHO - CDS     
;                   
; Name        : DIMREBIN
;               
; Purpose     : As REBIN, but dimensions supplied as an array
;               
; Explanation : With REBIN, the number of dimensions is hardcoded into the
;               function call.  This function takes an array with the sizes of
;               the dimensions of the result, and performs a REBIN call with
;               the correct number of dimensions.
;               
; Use         : array = DIMREBIN(ARRAY,DIMENSIONS)
;    
; Inputs      : ARRAY : the array to be rebinned.
;
;               DIMENSIONS : The dimensions of the result. As with rebin, the
;                            number of elements in the result must be the same
;                            as the number of elements in the input array.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns rebined array
;               
; Opt. Outputs: None.
;               
; Keywords    : SAMPLE : As in REBIN
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: Assumes sensible inputs
;               
; Side effects: None.
;               
; Category    : Array utility
;               
; Prev. Hist. : None.
;
; Written     : S. V. H. Haugan, UiO, 10 January 1997
;               
; Modified    : Not yet
;
; Version     : 1, 10 January 1997
;-            
FUNCTION dimrebin,array,dimensions,sample=sample
  
  samp = keyword_set(sample)
  
  d = dimensions
  
  CASE n_elements(dimensions) OF
     1: return,rebin(array,d(0),sample=samp)
     2: return,rebin(array,d(0),d(1),sample=samp)
     3: return,rebin(array,d(0),d(1),d(2),sample=samp)
     4: return,rebin(array,d(0),d(1),d(2),d(3),sample=samp)
     5: return,rebin(array,d(0),d(1),d(2),d(3),d(4),sample=samp)
     6: return,rebin(array,d(0),d(1),d(2),d(3),d(4),d(5),sample=samp)
     7: return,rebin(array,d(0),d(1),d(2),d(3),d(4),d(5),d(6),sample=samp)
     8: return,rebin(array,d(0),d(1),d(2),d(3),d(4),d(5),d(6),d(7),sample=samp)
  END
END
