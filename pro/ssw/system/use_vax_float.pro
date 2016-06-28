;+
; PROJECT:
;	SDAC
; NAME: 
;	USE_VAX_FLOAT
;
; PURPOSE:
;	This function modifies new VMS floating point to reconcile old VMS float format.
;
; CATEGORY:
;	GEN, UTIL, General Utility
;
; CALLING SEQUENCE:
;	x = use_vax_float( x_in, /old2current ) ;convert old format to new.
;	x = use_vax_float( x_in, /new2current ) ;convert new format to old.
;
; CALLS:
;	CONV_VAX_UNIX, CONV_UNIX_VAX, IDL_RELEASE, OS_FAMILY
;
; INPUTS:
;       X_in - input variable, may be structure, to convert.
;
; KEYWORD INPUTS:
;	OLD2NEW - takes old VAX float format and converts to IEEE.  
;	Use this when reading float data written in old format. 
;	This keyword is disabled if the compiled version of conv_vax_unix also makes the
;	conversion.  This function should normally be used in combination with 
;	conv_vax_unix, e.g. 
;	a = 0.0
;	openr, lu,/get,file
;	readu,lu,a
;	a = conv_vax_unix( use_vax_float(/old2new, a))
;	Normally, the call to conv_vax_unix would be present for transportable code.  The
;	newer versions of conv_vax_unix may do the conversion, in which case this part of
;	use_vax_float will be disabled.	
;
;	NEW2OLD - takes IEEE float format and converts to old by
;	running conv_unix_vax for non-vms architectures as will as vms for 5.1 and higher.  
;	Use this when writing float data to files with old format.
;	
;
; OUTPUTS:
;       Function returns input argument in same dimension and type.
;
; OPTIONAL OUTPUTS:
;	none
;
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Checks os and release and uses conv_vax_unix and conv_unix_vax as needed.
;
; MODIFICATION HISTORY:
;	Version 1. 24-Jun-1998, richard.schwartz@gsfc.nasa.gov
;	Version 2. 16-Jul-1998, richard.schwartz@gsfc.nasa.gov, enable X_in to be structures and
;	enable conversion of IEEE floating point to vax format on all platforms other than VMS.
;	The version must be 5.1 or higher on VMS.
;
;-
function use_vax_float, x_in, old2new=old2new, new2old=new2old

x  = x_in
typ= datatype( x, 2)
if typ eq 8 then begin
	ntags = n_tags(x)
	for i=0,ntags-1 do x.(i) = use_vax_float(x.(i), old2new=old2new, new2old=new2old)
	return, x
	endif

if typ lt 4 or typ eq 7 then return, x

if !version.os ne 'vms' and keyword_set(new2old) then begin
	conv_unix_vax, x 
	return,x
	endif

if !version.arch ne 'alpha' or !version.os ne 'vms'  or idl_release(upper=5.1) then return, x_in



if not ( conv_vax_unix( 1.0 ) eq conv_vax_unix( 1.0,target='mipsel')) and $
	keyword_set( old2new ) then x = conv_vax_unix(x, target='mipsel')

if keyword_set( new2old ) then  conv_unix_vax, x, source='mipsel'


return, x
end

