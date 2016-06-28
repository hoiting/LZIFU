;+
;
; PURPOSE:	Add two 2-d arrays, where the dimensions do not need to
;               be equal.  Allow the second array to be rotated 
;               (not yet implemented) and translated with respect 
;               to the first array. If (because of size difference or
;               translation) the second array is not added
;               completely into the first array, either clip (the default)
;               the part of the second array that 'hangs outside' of the
;               dimensions of the first, or expand the output array
;               to hold both arrays completely via the no_clip keyword.
;
; PARAMETERS:	
;	REQ:	arr1     - First array to be added to.
;	REQ:	arr2     - Array to be added to arr1
;
; OPTIONAL KEYWORDS:
;		x_tr     - x-translation of arr2 prior to addition to arr_1
;		y_tr     - y-translation of arr2 prior to addition to arr_1
;		rot_d    - degrees to rotate arr1 prior to addition to arr_1
;                          NOT CURRENTLY IMPLEMENTED
;               no_clip  - Return the array that is the union of the two
;                          arrays, with elements in neither set to zero.
;               min_thr1 - Minimum scalar threshold below which array values 
;                          from arr1 should not be added to the new composite array.
;               max_thr1 - Maximum scalar Threshold above which array values 
;                          from arr1 should not be added to the new composite array.
;               min_thr2 - Minimum scalar threshold below which array values 
;                          from arr2should not be added to the new composite array.
;               max_thr2 - Maximum scalar Threshold above which array values 
;                          from arr2 should not be added to the new composite array.
;               max_dim  - Maximum dimensions of output array.
;                          NOT CURRENTLY IMPLEMENTED
;               no_out   - If not no_clip, return array 1 if arrays have no
;                          overlap.  Default is to return an error.
;                          NOT CURRENTLY IMPLEMENTED
;		arr_av   - Averages the result of array addition by pixel.
;                          (divides each pixel by 1. or 2.); THIS WILL BE
;                          EXPANDED.
;
; OPTIONAL OUTPUT:
;               arr_tally - Array with same dimensions as output array, whose 
;                           integer entries count how many times each pixel 
;                           had a value added to it.  (This array can be used 
;                           to keep a running tally when this function is 
;                           called iteratively.) Must be the same dimensions 
;                           as 'arr1'.  NOT YET IMLEMENTED WITH NO_CLIP OPTION.
;                           
;
;
; HISTORY:     Jan-20-2000, Phil Shirts
;              May-26-2000, (PGS) allowed each array to have a max and min
;                                 threshold with, min_thr1, min_thr2, max_thr1,
;                                 max_thr2 INSTEAD of min_thr, max_thr.
;
;-
function add_arr, arr1, arr2, $
                  x_tr=x_tr, y_tr=y_tr, rot_d=rot_d, no_clip=no_clip, $
                  max_dim=max_dim, no_out=no_out, min_thr1=min_thr1,  $
                  min_thr2=min_thr2, max_thr1=max_thr1,               $  
                  max_thr2=max_thr2, arr_tally=arr_tally, arr_avg=arr_avg 
;***********
; INITIALIZE DEFAULT TRANSLATION VALUES:	
arr1 = float (arr1)
arr2 = float (arr2)
IF (1 - keyword_set(x_tr))    THEN x_tr    = 0 ; default x-translation
IF (1 - keyword_set(y_tr))    THEN y_tr    = 0 ; default y-translation
IF (keyword_set(rot_d)) THEN BEGIN 
   MESSAGE,/info, 'rot_d keyword is not yet implemented. rot_d set to 0.' 
   rot_d   = 0 ; default rotation
ENDIF
IF (keyword_set(max_dim)) THEN $
   MESSAGE,/info, 'max_dim keyword is not yet implemented.' 
IF (keyword_set(no_out)) THEN $
   MESSAGE,/info, 'no_out keyword is not yet implemented.' $
   ELSE no_out  = 0 ; 
IF (1 - keyword_set(min_thr1)) THEN min_thr1 = MIN([MIN(arr1),MIN(arr2)])
IF (1 - keyword_set(max_thr1)) THEN max_thr1 = MAX([MAX(arr1),MAX(arr2)])
IF (1 - keyword_set(min_thr2)) THEN min_thr2 = MIN([MIN(arr1),MIN(arr2)])
IF (1 - keyword_set(max_thr2)) THEN max_thr2 = MAX([MAX(arr1),MAX(arr2)])

IF (keyword_set(arr_tally) AND (keyword_set(no_clip)))   THEN BEGIN
   MESSAGE,'arr_tally is not, yet, implemented with the no_clip option'
ENDIF 
;
arr1_t = arr1
arr2_t = arr2
;
out_thresh_arr1 = where( ((arr1 LT min_thr1) OR  (arr1 GT max_thr1)) , $
                         num_out_thresh_arr1 )
out_thresh_arr2 = where( ((arr2 LT min_thr2) OR  (arr2 GT max_thr2)) , $
                         num_out_thresh_arr2 )
bet_thresh_arr1 = where( ((arr1 GE min_thr1) AND (arr1 LE max_thr1)) , $
                         num_bet_thresh_arr1 )
bet_thresh_arr2 = where( ((arr2 GE min_thr2) AND (arr2 LE max_thr2)) , $
                         num_bet_thresh_arr2 )
;
IF (num_out_thresh_arr1 GT 0) THEN arr1_t(out_thresh_arr1) = 0
IF (num_out_thresh_arr2 GT 0) THEN arr2_t(out_thresh_arr2) = 0
;
;CASE NUMBER 1: CLIP
;***********
;ROLL ALGORITHM: Roll array and then embed in a larger array, 
;                then apply x-y translations to the new array.
;     PLACEHOLDER: NOT CURRENTLY IMPLEMENTED.
;***********
; DETERMINE ARRAY ENDPOINTS AFTER TRANSLATIONS:
;***********
;Array endpoints for first array:
IF (size(arr1,/n_dimensions)  EQ 2 ) THEN BEGIN
   xA0 = 0
   xA1 = (size(arr1))(1) - 1
   yA0 = 0
   yA1 = (size(arr1))(2) - 1
ENDIF ELSE BEGIN
   message,/info,'First parameter must be a 2-d array'
   return,-1
ENDELSE
;
;Array endpoints for second image before truncation:
IF (size(arr2,/n_dimensions)  EQ 2 ) THEN BEGIN
x_tr = ROUND(x_tr)
y_tr = ROUND(y_tr)
   xB0 =              0  + x_tr
   xB1 = (size(arr2))(1) + x_tr - 1
   yB0 =              0  + y_tr
   yB1 = (size(arr2))(2) + y_tr - 1
ENDIF ELSE BEGIN
   message,/info,'Second parameter must be a 2-d array'
   return,-1
ENDELSE
;
;***********
; DETERMINE ARRAY_B ENDPOINTS AFTER "CLIPPING" TO FIT IN ARRAY_A:
;***********
;
IF (1-keyword_set(no_clip)) THEN BEGIN
   IF (1-keyword_set(arr_tally))  THEN arr_tally = arr1_t*0
   out_of_bounds = 0
   IF (xB0 GE xA0) THEN BEGIN   
      IF (xB0 LE xA1) THEN BEGIN
         IF (xB1 GT xA1) THEN xB1 = xA1
      ENDIF ELSE BEGIN
         out_of_bounds = 1
         MESSAGE, /info, 'Array2 is to the right of Array1'
         return,-1
      ENDELSE
   ENDIF 
;
   IF (xB0 LT xA0) THEN BEGIN          
      xB0 = xA0                 
      IF (xB1 LT xA0) THEN BEGIN
         out_of_bounds = 1
         MESSAGE, /info, 'Array2 is to the left of Array1'
         return,-1
      ENDIF ELSE BEGIN
         IF (xB1 GT xA1) THEN xB1 = xA1
      ENDELSE
   ENDIF
;
   IF (yB0 GE yA0) THEN BEGIN
      IF (yB0 LE yA1) THEN BEGIN
         IF (yB1 GT yA1) THEN yB1 = yA1
      ENDIF ELSE BEGIN
         out_of_bounds = 1
         MESSAGE, /info, 'Arrays Do Not Overlap: Array2 is above Array1'
         return,-1
      ENDELSE
   ENDIF
;
   IF (yB0 LT yA0) THEN BEGIN    
      yB0 = yA0                       
      IF (yB1 LT yA0) THEN BEGIN 
         out_of_bounds = 1
         MESSAGE, /info, 'Arrays Do Not Overlap: Array2 is below Array1'
         return,-1
      ENDIF ELSE BEGIN
         IF (yB1 GT yA1) THEN yB1 = yA1
      ENDELSE
   ENDIF
;
   comp_arr = arr1_t
   comp_arr(xB0:xB1,yB0:yB1) =    $
      comp_arr(xB0:xB1,yB0:yB1) + arr2_t((xB0-x_tr):(xB1-x_tr),(yB0-y_tr):(yB1-y_tr))
;
   tally_temp_arr1 = arr1*0
   IF ((num_bet_thresh_arr1 GT 0) AND  (MAX(arr_tally) EQ 0)) THEN tally_temp_arr1(bet_thresh_arr1) = 1 
   arr_tally = arr_tally + tally_temp_arr1 ; new pgs
;
   tally_temp_arr2 = arr2*0
   IF (num_bet_thresh_arr2 GT 0) THEN tally_temp_arr2(bet_thresh_arr2) = 1 
      arr_tally(MAX([xB0,0]):xB1,MAX([yB0,0]):yB1) =    $
         arr_tally(MAX([xB0,0]):xB1,MAX([yB0,0]):yB1) + $
         tally_temp_arr2(ABS(xB0-x_tr):ABS(xB1-x_tr),ABS(yB0-y_tr):ABS(yB1-y_tr))
;
   tally_gt_zero = where(arr_tally GT 0., num_tally_gt_zero)
   IF (num_tally_gt_zero GT 0) THEN BEGIN 
      IF ((keyword_set(arr_avg)) AND (num_tally_gt_zero GT 0)) THEN BEGIN
         comp_arr(tally_gt_zero) = $
            comp_arr(tally_gt_zero)/(1.*arr_tally(tally_gt_zero))
      ENDIF
      IF ((keyword_set(arr_avg)) AND (num_tally_gt_zero EQ 0)) THEN BEGIN
         message,/info,'No Average: no shared pixels!'
      ENDIF
   ENDIF
ENDIF 
;
;
;CASE NUMBER 2: NO CLIP
IF (keyword_set(no_clip)) THEN BEGIN
;MUST ENSURE THAT WE HAVE AN ARR_TALLY FOR THIS CASE!!! TODO pgs
   out_of_bounds = 0
;***********
; DETERMINE ENDPOINTS OF COMPOSITE "EXPANDED" ARRAY:
;***********
;Note: A = 'arr1', B = 'arr2'
   lsa = 0 ;which array extends to the left of comp_arr:   A=0,B=1
   rsa = 0 ;which array extends to the right of comp_arr:  A=0,B=1
   tsa = 0 ;which array extends atop of comp_arr:          A=0,B=1
   bsa = 0 ;which array extends below comp_arr:            A=0,B=1
;
;DETERMINE WHICH ARRAY EXTENDS "out" in each direction
   xC0 = MIN([xA0,xB0])
   IF (xA0 NE xC0) THEN lsa = 1 ; 1 => arrB is on left side
; 
   xC1 = MAX([xA1,xB1])
   IF (xA1 NE xC1) THEN rsa = 1 ; 1 => arrB is on right side
;
   yC0 = MIN([yA0,yB0])
   IF (yA0 NE yC0) THEN bsa = 1 ; 1 => arrB is on bottom
;
   yC1 = MAX([yA1,yB1])
   IF (yA1 NE yC1) THEN tsa = 1 ; 1 => arrB is on top
;
;***********
;BUILD EMPTY COMPOSITE ARRAY
;***********
;
;Step 1: build empty byte array of correct size
   comp_arr = bytarr(ABS(xC1-xC0)+1,ABS(yC1-yC0)+1) ; check not 'off' by one.
;Step 2: change array to correct type
   comp_arr = comp_arr*arr1(0,0)*arr2(0,0)
;
   comp_arr_tally = FIX(comp_arr)
;
;***********
; ADD ARRAY 'A' INTO COMPOSITE ARRAY
;***********
;
;Step 1: determine position of arr1 in comp_arr
   comp_arr(-lsa*x_tr:(size(arr1))(1)-lsa*x_tr-1, $
            -bsa*y_tr:(size(arr1))(2)-bsa*y_tr-1)=arr1_t
;
   IF (keyword_set(arr_tally)) THEN $
      comp_arr_tally(-lsa*x_tr:(size(arr1))(1)-lsa*x_tr-1, $
                     -bsa*y_tr:(size(arr1))(2)-bsa*y_tr-1) = arr_tally
;
   tally_arr1_t = where(comp_arr GT 0,num_tally_arr1_t)
   IF (num_tally_arr1_t GT 0) THEN comp_arr_tally(tally_arr1_t) = $
      comp_arr_tally(tally_arr1_t) + 1
;
;***********
; ADD ARRAY 'B' INTO COMPOSITE ARRAY
;***********
;
   comp_arr((1-lsa)*x_tr:(size(arr2))(1)-1+(1-lsa)*x_tr,    $
            (1-bsa)*y_tr:(size(arr2))(2)-1+(1-bsa)*y_tr) =  $
      comp_arr((1-lsa)*x_tr:(size(arr2))(1)-1+(1-lsa)*x_tr, $
               (1-bsa)*y_tr:(size(arr2))(2)-1+(1-bsa)*y_tr) + arr2_t
;
   arr2_tally = arr2_t*0
   tally_arr2_t = where(arr2_t GT 0,num_tally_arr2_t)
   IF (num_tally_arr2_t GT 0) THEN arr2_tally(tally_arr2_t) $
      = arr2_tally(tally_arr2_t) + 1.
   comp_arr_tally((1-lsa)*x_tr:(size(arr2))(1)-1+(1-lsa)*x_tr,   $
                  (1-bsa)*y_tr:(size(arr2))(2)-1+(1-bsa)*y_tr) = $
   comp_arr_tally((1-lsa)*x_tr:(size(arr2))(1)-1+(1-lsa)*x_tr,   $
                  (1-bsa)*y_tr:(size(arr2))(2)-1+(1-bsa)*y_tr) + arr2_tally
;
   arr_tally = comp_arr_tally
;
   IF (keyword_set(arr_avg)) THEN BEGIN
      comp_arr_tally_t = where(comp_arr_tally GT 0, num_comp_arr_tally)
      IF (num_comp_arr_tally GT 0) THEN BEGIN
         comp_arr(comp_arr_tally_t) = comp_arr(comp_arr_tally_t)/comp_arr_tally(comp_arr_tally_t)
      ENDIF  
   ENDIF
;
ENDIF
;
IF (out_of_bounds EQ 1) THEN return, -1
return, comp_arr
end
