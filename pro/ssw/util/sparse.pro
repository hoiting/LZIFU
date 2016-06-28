function sparse, input, index, lowcut=lowcut, highcut=highcut
;
;+
;   Name: sparse
;
;   Purpose: treat sparse matrices as stream for memory conservation
;
;	     For example, for large array which is mostly zeros, store
;	     only the non-zero values.
;
;   Input Paramters:
;      input - if structure, convert sparse structure to array
;	       if array,   , convert array to sparse structure
;      index - (optional) only convert specified index (must be scalar)
;
;   Input Keyword Parameters:
;      lowcut  - low value cutoff  (currently,only used with data->structure) 
;      highcut - high value cutoff (currently,only used with data->structure) 
;   
;   Calling Sequence:
;       structure=sparse(data [,lowcut=lowcut,highcut=highcut])
;	structure=sparse(data)	; sparse data array in, sparse structure out
;	structure=sparse(data,low=1)	; Save values where data ge 1
;	
;	data=sparse(structure)  ; sparse structure in, sparse data array out
;	data=sparse(structure,index) ; 3D arrays only, only specified 2D out  
;				     ; Index is the index of the 3rd dimension.
;
;   History:
;      slf - 24-feb-1993 -- Minor mods by JRL
;
;   Restrictions:
;      proto - needs some more type/data size checking
;-
;
; ---------------------- check out input ----------------------------------
sinput=size(input)
nsinput=n_elements(sinput)
datatype =sinput(nsinput-2)
; -------------------------------------------------------------------------
case datatype of
; ----------------------- structure -> array ------------------------------
      8: begin						
	    names=tag_names(input)
	    if names(0) ne 'SIZE' or names(1) ne 'CUTOFFS' then begin
               message,/info,'SPARSE structure expected, returning,...
	       return,input
	    endif
            ds=input.size(0:input.size(0)+2)		; data size
            if n_elements(index) eq 0 then begin	; do full arrayt
	       output=make_array(size=ds)		; make zeroed array
	       temp=input.ss
	       if temp(0) ne -1 then $			; can't do with tag.
		   output(input.ss)=input.values	; recreate sparse 
	    endif else begin				; index specified
	       if (ds(0) eq 3) or (index eq 0) then begin
		  if (ds(0) ge 3) and (index+1 gt ds(3)) then begin
			message,/info,' ** Error:  index is out of range = '+string(index)
			output = input
		  endif else begin
;	    -------------------- handle indexing function -------------------
;			   ---------- could generalize for > 2D -------------
			   nsize=[2,ds(1:2),ds(ds(0)+1),ds(1)*ds(2)]
			   output=make_array(size=nsize)
			   sslow=index*nsize(4)
			   sshigh=(index+1)*nsize(4)-1
			   wss=where(input.ss ge sslow and $
					input.ss le sshigh, wsscount)
			   if wsscount gt 0 then begin
			      wssoff=input.ss(wss)-sslow
			      output(wssoff)=input.values(wss)
			   endif
		  endelse
	       endif else begin
			message,/info,'index only supported for 3D arrays
			output=input
	       endelse
	       ; -----------------------------------------------------------
	    endelse				; Index supplied
         endcase
;  -------------------------------------------------------------------------
;
;  ---------------------- array -> structure --------------------------------
   else: begin						
  	    if not keyword_set(lowcut)  then lowcut = min(input)		
	    if not keyword_set(highcut) then highcut= max(input)	
;	    ------------- define tag values --------------------------------
	    ssvec=where(input ge lowcut and input le highcut,sscount)
            sstag=fmt_tag(size(ssvec))
	    valtag="-1"
	    values=0				; initialize
            if sscount gt 0 then begin
	       values=input(ssvec)
	       valtag=fmt_tag(size(values))
            endif               

;	    ------------- define the sparse structure --------------------
            sparse_str=		   	  $
		"{dummy,"	   	+ $
		" size:lonarr(15),"	+ $	; idl 'size' of input array
		" cutoffs:fltarr(2),"	+ $	; low and high cutoff
		" ss:" + sstag + ","	+ $	; success vector
		" values:" + valtag + "}"	; corresponding values
	    sparse_str=make_str(sparse_str)	; string to structure
;	    ---------------------------------------------------------------
;	    -------------- copy values to structure -----------------------
	    temp=sparse_str.size		; can't go directly into tag
            temp(0)=sinput
	    sparse_str.size=temp
	    sparse_str.ss=ssvec
	    sparse_str.values=values
	    sparse_str.cutoffs=[lowcut,highcut]
	    output=sparse_str
	 endcase			
;  -------------------------------------------------------------------------
endcase

return,output
end
