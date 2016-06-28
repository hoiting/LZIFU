;+
; NAME: 
;	DELVARX
; PURPOSE: 
; 	Delete variables for memory management (can call from routines) 
; EXPLANATION:
;	Like intrinsic DELVAR function, but can be used from any calling level
;
; CALLING SEQUENCE:
; 	DELVARX,  a [,b,c,d,e,f,g,h,i,j, /FREE_MEM]
;
; INPUTS: 
;	p0, p1...p9 - variables to delete
;
; OPTIONAL KEYWORD:
;       /FREE_MEM - If set, then free memory associated with pointers 
;                   and objects (automatically handled by HEAP_FREE)
;       OLD - use old DELVARX
; RESTRICTIONS: 
;      None
;
; METHOD: 
;	Uses EXECUTE and TEMPORARY function (not anymore)   
;
; REVISION HISTORY:
;	Copied from the Solar library, written by slf, 25-Feb-1993
;	Added to Astronomy Library,  September 1995
;	Converted to IDL V5.0   W. Landsman   September 1997
;       Modified, 26-Mar-2003, Zarro (EER/GSFC) 
;       - added FREE_MEM to free pointer/objects
;       Modified, 25-Apr-2006, Zarro (L-3Com/GSFC)
;       - removed EXECUTE for compliance with IDL VM
;       - used SCOPE_VARFETCH to dynamically extract value from argument name
;       - used HEAP_FREE for improved memory management 
;       Modified 26-Jan-2006, Zarro (ADNET/GSFC)
;       - added call to old DELVARX (in DELVARX2) for backwards compatibility
;
;-

pro delvarx,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,_extra=extra,old=old

forward_function scope_varfetch

new=(1-keyword_set(old))
if since_version('6.1') and new then begin

;-- Construct variable name 'p0', 'p1', etc
;-- Extract variable value using scope_varfetch
;-- If value exists, copy it into a pointer then free the pointer

 for i=0,n_params()-1 do begin
  var_name='p'+strtrim(string(i),2)
  if n_elements((scope_varfetch(var_name,level=0))) ne 0 then $
   heap_free,ptr_new((scope_varfetch(var_name,level=0)),/no_copy)
 endfor

 return
endif

;-- pre v6.1

delvarx2,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,_extra=extra

return & end
