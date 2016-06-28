;+
;$Id: uniq_nosort.pro,v 1.1 2007/01/12 22:41:51 nathan Exp $
;
; Project     : SOHO - LASCO, STEREO - SECCHI 
;
; Name        : UNIQ_NOSORT
;
; Purpose     : Return the subscripts of the unique elements in an array.
;               Does not require array to be sorted (as in UNIQ).
;
; Use         : UNIQ_NOSORT(Array)
;
; Inputs      : Array  The array to be scanned.  
;
; Opt. Inputs : None
;
; Outputs     : An array of indicies into ARRAY is returned.  The expression:
;               ARRAY(UNIQ_NOSORT(ARRAY))
;               will be a copy of the sorted Array with duplicate elements removed.
;
; Opt. Outputs: None
;
; Keywords    : None
;
; Prev. Hist. : Adapted from SOHO/LASCO planning tool.
;
; Written     : Scott Paswaters, NRL, Dec 1996.
;
; @(#)uniq_nosort.pro   1.1 05/14/97 :NRL Solar Physics
;               
; Modification History:
;
; $Log: uniq_nosort.pro,v $
; Revision 1.1  2007/01/12 22:41:51  nathan
; moved from nrl_lib/dev/database
;
; Revision 1.1  2005/10/26 14:41:30  esfand
; Secchi database routines.
;
;-

;__________________________________________________________________________________________________________
;
FUNCTION UNIQ_NOSORT, a

   len = N_ELEMENTS(a)
   used = BYTARR(len)
   new = 0
   ind = WHERE(a EQ a(0))
   used(ind) = 1
   FOR i=1L, len-1 DO BEGIN
      IF (used(i) EQ 0) THEN BEGIN
         new = [new, i]
         ind = WHERE(a EQ a(i))
         used(ind) = 1
      ENDIF
   ENDFOR

   RETURN, new

END
