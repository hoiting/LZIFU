;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: funcir.pro
; Created by:    Liyun Wang, GSFC/ARC, November 10, 1994
;
; Last Modified: Sun Nov 13 21:13:44 1994 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO FUNCIR, x, a, y, dyda
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       FUNCIR
;
; PURPOSE: 
;       Return function value and its derivatives of the equation of a circle
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       FUNCIR, x, a, y, dyda
;
; INPUTS:
;       X -- A two element vector for position of the point on the circle
;       A -- A three element vector representing position (x0, y0) and radius
;            (r0) of the circle center 
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Y    -- Function value of the circle equation.
;       DYDA -- Derivatives of the function
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Misc, user-supplied function
;
; PREVIOUS HISTORY:
;       Written November 10, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, November 10, 1994
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(x) NE 2 OR N_ELEMENTS(a) NE 3 THEN $
      MESSAGE, 'Number of parameters wrong, check FUNCIR'
   r = SQRT((x(0)-a(0))^2+(x(1)-a(1))^2)
   y = r-a(2)	
   dyda = a
   dyda(0) = (a(0)-x(0))/r
   dyda(1) = (a(1)-x(1))/r
   dyda(2) = -1.0
END
