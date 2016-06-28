function get_kbrd2,wait
;
;+ 
;   Name: get_kbrd
;
;   Purpose: same as IDL get_kbrd unless SGI ( mabey future additions)
;	     SGI appears to solicit bogus 255 from Xclients
;
;-
bogus_sys=['irix']		
bogus_sys=strlowcase(bogus_sys)
sys=where(strlowcase(!version.os) eq bogus_sys)
;
if n_params() eq 0 then wait=0
case sys(0) of 
   -1:retval = get_kbrd(wait)	; default action if not in bogus sys
   else: repeat retval=get_kbrd(wait) until retval ne string(255b)  
endcase
return,retval
end
