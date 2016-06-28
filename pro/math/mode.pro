;+
; NAME:
; mode
;
;
; PURPOSE:
; compute the moe of an array (most common element)
;
;
; CATEGORY:
; stats
;
;
; INPUTS:
; array: array to calculate the mode of
;
;
; OUTPUTS:
; mode of the array
;
;
;
; PROCEDURE:
; ;; this is based on 
;http://groups.google.com/group/comp.lang.idl-pvwave/browse_frm/thread/5684fa0a0c48b908/ad39df87b64b8567?lnk=gst&q=mode&rnum=3#ad39df87b64b8567
;
;
; EXAMPLE:
; IDL> print, mode([findgen(10),2])
;      2.00000
;
;
;
; MODIFICATION HISTORY:
;
;       Mon Nov 26 13:08:27 2007, Brian Larsen
;		changed from sort to bsort
;       Mon Nov 26 09:42:06 2007, Brian Larsen
;		documented, written previously
;
;-
FUNCTION mode, narray
  array=narray
  array=array[bsort(array)]
  wh=where(array NE shift(array,-1),cnt)
  IF cnt EQ 0 THEN mode=array[0] ELSE BEGIN 
     void=max(wh-[-1,wh],mxpos)
     mode=array[wh[mxpos]]
  ENDELSE
  
  return, mode
  
END 
