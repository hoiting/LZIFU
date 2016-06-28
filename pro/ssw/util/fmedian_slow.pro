;+
; Project     : SOHO - CDS     
;                   
; Name        : FMEDIAN_SLOW
;               
; Purpose     : FMEDIAN routine without CALL_EXTERNAL 
;               
; Explanation : See fmedian.pro/built-in median routine.
;               
; Use         : RESULT = FMEDIAN(ARRAY, [, NW1 [, NW2]])
;    
; Inputs      : See fmedian.pro
;               
; Opt. Inputs : See fmedian.pro
;               
; Outputs     : See fmedian.pro
;               
; Opt. Outputs: See fmedian.pro
;               
; Keywords    : See fmedian.pro
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: ARRAY must be either one or two dimensional. No parameters are
;               checked, since this routine is supposed to be called only from
;               within FMEDIAN().
;               
; Side effects: None.
;               
; Category    : Utilities, Arrays
;               
; Prev. Hist. : Fortran version was a SERTS routine.
;
; Written     : William Thompson, August 1991 (Call_external version)
;              
; Modified    : Version 1, S.V.H.Haugan, UiO, 9 October 1996
;                       Added MISSING keyword, added non-call_external code.
;               Version 2, S.V.H.Haugan, UiO, 9 January 2008
;                       Added ONLY_MISSING keyword
;
; Version     : 1, 9 October 1996
;-            

FUNCTION fmedian_slow,array,n_w1,n_w2,missing=missing_in,only_missing=only_missing
  always = NOT keyword_set(only_missing)
  
  dim = size(array)
  
  ;;
  ndim1 = dim(1)
  ndim2 = dim(2)
  
  IF dim(0) EQ 1 THEN ndim2 = 1
  
  nw1 = (n_w1-1)/2
  nw2 = (n_w2-1)/2
  
  out = array
  
  FOR j = 0,ndim2-1 DO BEGIN
     j1 = (j-nw2) > 0
     j2 = ((j+n_w2-nw2-1) < (ndim2-1)) > 0
     FOR i = 0,ndim1-1 DO BEGIN
        I1 = (I-nw1) > 0
        I2 = (I+N_W1-NW1-1) < (ndim1-1)
        
        ;; Fetch data if necessary
        IF always OR array[i,j] EQ MISSING_IN THEN BEGIN 
           sub = array(i1:i2,j1:j2)
           good = sub([where(sub NE MISSING_IN,N)])
           
           CASE n OF 
              0 : ;; Do nothing- missing already there
              1 : out(i,j) = good(0)
              2 : out(i,j) = (good(0)+good(1))*0.5
              ELSE: out(i,j) = median(good)
           END
        END
     END
  END
  
  return,out
END

        
