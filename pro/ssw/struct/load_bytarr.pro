;+
;
; NAME: 
;
;
; PURPOSE:  fill  byte arrays from structures
;
; CATEGORY: i/o
;
;
; CALLING SEQUENCE: load_bytarr,  str, buffer, error=error
;            
; CALLED BY:  read... in SPEX directories
;
; calls to: datatype, conv_vax_unix
;
; INPUTS:
;       str    - input structure, each element of the structure must
;		be of numerical daytype, byte, long, fix, float, double or
;		complex
;		 
; OUTPUTS:
;       buffer - byte array, may be dimensioned m x nrep where nrep is the
;	error  - set to 1 if a string is one of the structure elements
;
; RESTRICTIONS: No strings are permitted among the structure elements
;
;
; MODIFICATION HISTORY: ras, 12-apr-95, based on load_struct
;       Version 2, 27-Feb-2006, William Thompson, GSFC
;               Modified for newer data types.  Treat structures recursively.
;       Version 3, 31-Mar-2006, William Thompson, GSFC
;               Fixed bug in recursive structures
;-

pro load_bytarr,  str, buffer,  error=error


error=1 
ntags = n_elements(tag_names(str))
nrep = n_elements(str)
datatypes = lonarr(ntags)
nels = lonarr(ntags)

for i=0,ntags-1 do begin
	datatypes(i)=datatype( str(0).(i), 2)
	nels(i)     =n_elements( str(0).(i) )
endfor

;       typ = datatype string or number.   out
;          flag = 0       flag = 1           flag = 2       flag = 3
;          UND            Undefined          0              UND
;          BYT            Byte               1              BYT
;          INT            Integer            2              INT
;          LON            Long               3              LON
;          FLO            Float              4              FLT
;          DOU            Double             5              DBL
;          COM            Complex            6              COMPLEX
;          STR            String             7              STR
;          STC            Structure          8              STC
;          DCO            DComplex           9              DCOMPLEX
;          PTR            Pointer           10              PTR
;          OBJ            Object            11              OBJ
;          UIN            UInt              12              UINT
;          ULO            ULong             13              ULON
;          L64            Long64            14              LON64
;          U64            ULong64           15              ULON64
typ_2_num = [0,1,2,4,4,8,8,0,0,16,0,0,2,4,8,8]
bytes_per_tag = typ_2_num(datatypes)*nels
total_bytes = total( bytes_per_tag)

buffer = bytarr(total_bytes, nrep)

ptr = 0 ;starting byte of next structure element

for i=0,ntags-1 do begin
	a = str.(i)
	type = datatype(a(0))
	nel = n_elements(str(0).(i))
	case type of
	'BYT': begin
		buffer(ptr:ptr+nel-1,*) = a(*)
		ptr = ptr + nel
	end
	'INT': begin
		buffer(ptr:ptr+nel*2-1,*)= byte(a(*),0,2*nel,nrep)
		ptr = ptr +  nel*2
	end
	'LON': begin
		buffer(ptr:ptr+nel*4-1,*) = byte(a(*),0,4*nel,nrep)
		ptr = ptr+ nel*4
	end
	'FLO': begin
		buffer(ptr:ptr+nel*4-1,*) = byte(a(*),0,4*nel,nrep)
		ptr = ptr+ nel*4
	end
	'DOU': begin
		buffer(ptr:ptr+nel*8-1,*) = byte(a(*),0,8*nel,nrep)
		ptr = ptr+ nel*8
	end
	'COM': begin
		buffer(ptr:ptr+nel*8-1,*) = byte(a(*),0,8*nel,nrep)
		ptr = ptr+ nel*8
	end
	'STC': begin
                load_bytarr, a, b, error=error
                if error then return
                length = (size(b))(1)
                total_bytes = total_bytes + length
                oldbuf = temporary(buffer)
                buffer = bytarr(total_bytes, nrep)
                if ptr gt 0 then buffer(0:ptr-1,*) = oldbuf(0:ptr-1,*)
                buffer(ptr:ptr+length-1,*) = b
	      	ptr = ptr+ length	       
        end
        'DCO': begin
                buffer(ptr:ptr+nel*16-1,*) = byte(a(*),0,16*nel,nrep)
                ptr = ptr+ nel*16
        end
        'UIN': begin
                buffer(ptr:ptr+nel*2-1,*) = byte(a(*),0,2*nel,nrep)
                ptr = ptr+ nel*2
        end
        'ULO': begin
                buffer(ptr:ptr+nel*4-1,*) = byte(a(*),0,4*nel,nrep)
                ptr = ptr+ nel*4
        end
        'L64': begin
                buffer(ptr:ptr+nel*8-1,*) = byte(a(*),0,8*nel,nrep)
                ptr = ptr+ nel*8
        end
        'U64': begin
                buffer(ptr:ptr+nel*8-1,*) = byte(a(*),0,8*nel,nrep)
                ptr = ptr+ nel*8
        end
	'STR': begin
		message, 'Does not work with strings. Error!'
		return
	end
	'PTR': begin
		message, 'Does not work with pointers. Error!'
		return
	end
	'OBJ': begin
		message, 'Does not work with objects. Error!'
		return
	end
	endcase
endfor

;if keyword_set(noieee) then str=conv_vax_unix(str) $
;      else ieee_to_host, str

error = 0
end
