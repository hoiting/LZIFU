function minmax,array,NAN=nan, DIMEN=dimen, $
	SUBSCRIPT_MAX = subscript_max, SUBSCRIPT_MIN = subscript_min
;+
; NAME:
;      MINMAX
; PURPOSE:
;      Return a 2 element array giving the minimum and maximum of an array
; EXPLANATION:
;      Using MINMAX() is faster than doing a separate MAX and MIN.
;
; CALLING SEQUENCE:
;      value = minmax( array )
; INPUTS:
;      array - an IDL numeric scalar, vector or array.
;
; OUTPUTS:
;      value = a two element vector (if DIMEN is not supplied)
;            value[0] = minimum value of array
;            value[1] = maximum value of array
;
;            If the DIMEN keyword is supplied then value will be a 2 x N element
;            array where N is the number of elements in the specified
;            dimension
;              
; OPTIONAL INPUT KEYWORDS:
;      /NAN   - Set this keyword to cause the routine to check for occurrences
;            of the IEEE floating-point value NaN in the input data.  Elements 
;            with the value NaN are treated as missing data.
;
;      DIMEN - (V5.5 or later) integer (either 1 or 2) specifying which 
;            dimension of a 2-d array to  take the minimum and maximum.   Note
;            that DIMEN is only valid for a 2-d array, larger dimensions are 
;            not supported.
;
; OPTIONAL OUTPUT KEYWORDS:
;      SUBSCRIPT_MAX and SUBSCRIPT_MIN  Set either of these keywords to 
;            named variables to return the subscripts of the MIN and MAX
;	     values (V5.5 or later).
; EXAMPLE:
;     (1)  Print the minimum and maximum of an image array, im
; 
;            IDL> print, minmax( im )
;
;     (2) Given a 2-dimension array of (echelle) wavelengths w, print the
;         minimum and maximum of each order (requires V5.5 or later)
;
;         print,minmax(w,dimen=1)
;
; PROCEDURE:
;      The MIN function is used with the MAX keyword
;
; REVISION HISTORY:
;      Written W. Landsman                January, 1990
;      Converted to IDL V5.0   W. Landsman   September 1997
;      Added NaN keyword.      M. Buie       June 1998
;      Added DIMENSION keyword    W. Landsman  January 2002
;      Added SUBSCRIPT_MIN and SUBSCRIPT_MAX  BT Jan 2005
;      Check for IDL 5.5 or later, W. Thompson, 24-Feb-2005
;-
 On_error,2
 if !version.release ge '5.5' then begin
   if N_elements(DIMEN) GT 0 then begin
      amin = min(array, subscript_min, $
      	MAX = amax, NAN = nan, DIMEN = dimen, SUBSCRIPT_MAX = subscript_max) 
      return, transpose( [[amin], [amax] ])
   endif else  begin 
     amin = min( array, subscript_min, $
     	MAX = amax, NAN=nan, SUBSCRIPT_MAX = subscript_max)
     return, [ amin, amax ]
   endelse
 end else begin
   amin = min( array, MAX = amax, NAN=nan)
   return, [ amin, amax ]
 endelse
 end
