PRO BITS, invalue, BITARR, qprint
;
;+
;NAME:
;	bits
;PURPOSE:
;	Given a byte or integer, return a vector of 8 or 16 values
;	which are the binary representation of the value.
;INPUT:
;	invalue	- The byte or integer value to check
;OUTPUT:
;	bitarr	- The 8-element array with values set
;		  if the bit is set
;HISTORY:
;	Written 1988 by M.Morrison
;	13-Nov-92 (MDM) - Modified to allow integer*2 values
;			  and to allow an array of values.
;	 7-Apr-94 (MDM) - Allow integer*4 values
;	15-Aug-94 (MDM) - Corrected error from 7-Apr-94 mod which
;			  did not allow an array of inputs
;-
;
if (n_elements(qprint) eq 0) then qprint = 0
;
n = n_elements(invalue)
siz = size(invalue)
typ = siz( siz(0)+1 )
nbit = 8
if (typ ne 1) then nbit = 16
if (max(invalue) gt 256*128L) then nbit = 32
;
bitarr = bytarr(nbit, n)
;
for ival=0,n-1 do begin
    if (nbit eq 8) then val = byte(invalue(ival)) else val = long(invalue(ival))
    if (nbit eq 32) and (invalue(ival) lt 0) then val = val + 2.^32
    ;
    FOR I=nbit-1,0,-1 DO IF (val GE 2.^I) THEN BEGIN
	BITARR(I,ival) = 1
	val=val - 2.^I
    END
    ;
    if (qprint) then begin
	str = string(long(invalue(ival))) + '  =  '
	str = str + string(reverse(fix(bitarr(*,ival))), format='(4(1x,4i1,1x,4i1))')
	print, str
    end
end
;
RETURN
END
