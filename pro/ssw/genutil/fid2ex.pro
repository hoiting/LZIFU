function fid2ex, fid
;
;+
;NAME:
;	fid2ex
;PURPOSE:
;	Given a fileID, generate the 7-element time array
;CALLING SEQUENCE:
;	tarr = fid2ex(fid) 
;INPUT:
;	fid 
;HISTORY:
;	Written 11-Dec-91 by M.Morrison
;	24-Aug-92 (MDM) - Modified to accept an array of FIDs
;	 5-Jan-93 (MDM) - Modified to handle case where there are blank
;			  spaces in funny places
;-
;
n = n_elements(fid)
tarr = intarr(7,n)
;
for i=0,n-1 do begin
    fid0 = strcompress(fid(i), /remove_all)
    tarr(6,i) = fix(strmid(fid0, 0, 2))
    tarr(5,i) = fix(strmid(fid0, 2, 2))
    tarr(4,i) = fix(strmid(fid0, 4, 2))
    ;
    tarr(0,i) = fix(strmid(fid0, 7, 2))
    tarr(1,i) = fix(strmid(fid0, 9, 2))
    tarr(2,i) = fix(strmid(fid0, 11, 2))
end
if (n eq 1) then tarr = tarr(*,0)	;turn back into 1-D
;
return, tarr
end
