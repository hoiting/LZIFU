;+
;
; NAME:
;
;
; PURPOSE:  fill structures from byte arrays
;	Assumes byte array comes from data in ieee format
;	like in the fits format coming from the GROSSC archive.
;	If data was originally written on VMS, like BATSE native
;	format files, then use /noiee
;
; CATEGORY: i/o
;
;
; CALLING SEQUENCE: load_struct, buffer, substr, str, error=error, /noieee
;
; CALLED BY:  read... in SPEX directories
;
; calls to: datatype, conv_vax_unix
;
; INPUTS:
;       buffer - byte array, may be dimensioned m x nrep where nrep is the
;		 structure repeat factor
;	substr - data structure being loaded, single element
; OUTPUTS:
;       str    - output structure
;	error  - set to 1 if a string is one of the structure elements
; KEYWORDS:
;	noieee   - optional, if set then input bytes not in ieee format
;		   but are assumed to have been written on a VMS machine
;	nbytes   - optional, a vector of the bytes for each tag, if
;		this is given, then the structure can contain string tags.
;		tag(i) can be fixed with the input substr value if
;		nbytes(i) is set to zero
;	noconv   - optional, if set then conv_vax_unix isn't called
;       little   - optional, bytes written on a little-endian machine.  Call
;                  swap_endian,/swap_if_big_endian instead of conv_vax_unix or
;                  ieee_to_host.
;
; RESTRICTIONS: No strings are permitted among the structure elements
;
;
; MODIFICATION HISTORY: ras, 2-feb-94
;	RAS, 25-Aug-1996, enhanced string processing and noconv options
; Version:
;	Version 2, 25-aug-1996
;	ras, 24-oct-2001
;	changed to protect against dimension change (1xN) not N for structure fields in replicated structures
;       Version 4, 27-Feb-2006, William Thompson, GSFC
;               Modified for newer data types.  Added /LITTLE
;       Version 5,  6-Apr-2006, William Thompson, GSFC
;               Made /LITTLE pre-5.6 compatible
;       Version 6,  3-Apr-2008, William Thompson, GSFC
;               Change /LENGTH to /DATA_LENGTH.  Fixed bug calling recursively.
;-

pro load_struct, buffer, substr, str, error=error, $
	noieee=noieee, nbytes=nbytes, noconv=noconv, little=little


error=1
ntags = n_elements(tag_names(substr))
nrep = n_elements(buffer(0,*))
str = replicate( substr, nrep)

ptr = 0 ;starting byte of next structure element

for i=0,ntags-1 do begin

	a = str.(i)

	type = datatype(substr.(i))
	nel = n_elements(substr.(i))
                if n_elements(nbytes) ge 1 then  type=(['NONE',type])(nbytes(i)<1)
	case type of
	'BYT': begin
		a(*) = buffer(ptr:ptr+nel-1,*)
		ptr = ptr + nel
	end
	'INT': begin
		a(*) = fix(buffer(ptr:ptr+nel*2-1,*),0,nel,nrep)
		ptr = ptr +  nel*2
	end
	'LON': begin
		a(*) = long(buffer(ptr:ptr+nel*4-1,*),0,nel,nrep)
		ptr = ptr+ nel*4
	end
	'FLO': begin
		a(*) = float(buffer(ptr:ptr+nel*4-1,*),0,nel,nrep)
		ptr = ptr+ nel*4
	end
	'DOU': begin
		a(*) = double(buffer(ptr:ptr+nel*8-1,*),0,nel,nrep)
		ptr = ptr+ nel*8
	end
	'COM': begin
		a(*) = complex(buffer(ptr:ptr+nel*8-1,*),0,nel,nrep)
		ptr = ptr+ nel*8
	end
	'STC': begin
	        length = n_tags( /data_length, substr.(i))
	        load_struct, buffer(ptr:ptr+length-1,*),substr.(i), a, $
                  error=error, /noieee, /noconv
	        if error then return
	      	ptr = ptr+ length
 	       end
	'DCO': begin
		a(*) = dcomplex(buffer(ptr:ptr+nel*16-1,*),0,nel,nrep)
		ptr = ptr+ nel*16
	end
	'UIN': begin
		a(*) = uint(buffer(ptr:ptr+nel*2-1,*),0,nel,nrep)
		ptr = ptr+ nel*2
	end
	'ULO': begin
		a(*) = ulong(buffer(ptr:ptr+nel*4-1,*),0,nel,nrep)
		ptr = ptr+ nel*4
	end
	'L64': begin
		a(*) = long64(buffer(ptr:ptr+nel*8-1,*),0,nel,nrep)
		ptr = ptr+ nel*8
	end
	'U64': begin
		a(*) = ulong64(buffer(ptr:ptr+nel*8-1,*),0,nel,nrep)
		ptr = ptr+ nel*8
	end
	'STR': begin
		if keyword_set(nbytes) then begin
		nel  = nbytes(i)
		a(*) = string(buffer(ptr:ptr+nel-1,*))
		ptr = ptr+ nel
		endif  else begin
		print, 'LOAD_STRUCT does not work with strings without NBYTES keyword. Error!'
		return
		endelse
	end
	else:
	endcase
	;was just str.(i) = a
;changed to protect against dimension change (1xN) not N for structure fields in replicated structures
;ras, 24-oct-2001
	dim = size( str.(i), /dim )
	if (dim[0] ge 1 ) then $
	str.(i)= reform( a, size(str.(i),/dim)) else str.(i) = a
endfor

if keyword_set(little) then begin
    test = 1
    byteorder, test, /swap_if_big_endian
    if test ne 1 then str = swap_endian(str)
end else begin
    if keyword_set(noieee) then begin
        if not keyword_set(noconv) then  str=conv_vax_unix(str)
    endif else ieee_to_host, str
endelse

error = 0
end
