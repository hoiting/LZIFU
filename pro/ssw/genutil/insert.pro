pro insert, array_out, array_in, ist1, ist2, ist3
;
;+
;NAME:
;	insert
;PURPOSE:
;	To insert a smaller array into a larger array
;	IDL Ver 2 does not have it (Ver 1 did)
;INPUT/OUTPUT:
;	array_out - Array into which the smaller array
;		    should be inserted
;INPUT:
;	array_in  - Array to be inserted
;	ist1	  - Indicie in the large array where
;		    "array_in" is to be inserted.
;	ist2	  -
;	ist3	  -
;HISTORY:
;	Written Aug-91 by M.Morrison
;-
;
case n_params(0) of 
    3: array_out(ist1) = array_in
    4: array_out(ist1,ist2) = array_in
    5: array_out(ist1,ist3) = array_in
endcase
;
end
