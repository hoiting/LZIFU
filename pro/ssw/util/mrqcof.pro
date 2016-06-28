;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: mrqcof.pro
; Created by:    Liyun Wang, GSFC/ARC, November 10, 1994
;
; Last Modified: Mon Mar 13 14:20:33 1995 (lwang@achilles.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       MRQCOF
;
; PURPOSE: 
;       Internal routine called by MRQMIN
;
; EXPLANATION:
;       Used by MRQMIN to evaluate the linearized fitting matrix
;       ALPHA, and vector ZETA.
;
; CALLING SEQUENCE: 
;       MRQCOF, 
;
; INPUTS:
;       X   -- A matrix with M x N elements containing the observation points,
;              where M is the number of independent variables, and N is the
;              number of observing points.
;       Y   -- N element vector, value of the fitted function. 
;       SIG -- Measurement error (standard deviation, N elements); If the
;              measurement errors are not know, they can all be set to 1.
;       A   -- M element vector, initial and final parameters to be solved.
;       FUNCS -- Name of the user-supplied procedure that returns values of
;                the model function and its first derivative. Its calling
;                sequence must be:
;                     FUNCS, x0, a, ymod, dyda
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       ALPHA -- M x M array, curvature matrix 
;       ZETA  -- M-element vector, solution of the linear equation associated
;                with the curvature matrix
;       CHISQ -- Value of the merit function
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       FUNCS, the user-supplied procedure.
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
;       Utility, numerical calculation
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
PRO MRQCOF, x, y, sig, a, alpha, zeta, chisq, funcs=funcs
   ON_ERROR, 2
   IF N_PARAMS() NE 7 THEN MESSAGE, 'Require 7 parameters.'
;----------------------------------------------------------------------
;  Check size of input parameters
;----------------------------------------------------------------------
   size_x = SIZE(x)
   IF size_x(0) NE 2 THEN MESSAGE, 'Invalid matrix.'
   mx = size_x(1)
   ndata = size_x(2)
   ma = N_ELEMENTS(a)
   FOR j = 1, ma DO BEGIN
      alpha(j-1, 0:j-1)=0.
   ENDFOR
   zeta = fltarr(ma)
   chisq = 0.0
   FOR i = 0, ndata-1 DO BEGIN
      x0 = x(*,i)
      CALL_PROCEDURE,funcs,x0,a,ymod,dyda
      sig2i = 1./(sig(i)*sig(i))
      dy = y(i)-ymod
      FOR j = 1, ma DO BEGIN
         wt = dyda(j-1)*sig2i
         alpha(j-1,0:j-1) = alpha(j-1,0:j-1)+wt*dyda(0:j-1)
         zeta(j-1) = zeta(j-1)+dy*wt
      ENDFOR
      chisq = chisq+dy*dy*sig2i
   ENDFOR
   FOR j = 2, ma DO BEGIN
      FOR k = 1, j-1 DO BEGIN
         alpha(k-1,j-1)=alpha(j-1,k-1)
      ENDFOR
   ENDFOR
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
