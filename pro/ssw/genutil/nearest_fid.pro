	FUNCTION nearest_fid, tfid, fidslst
;	---------------------------------------------------------------
;+							6-May-94
;	NAME: nearest_fid
;	Purpose: Using the input fid "tfid" find and return the index 
;		to the nearest fid from the list of fileids fids.
;	Calling Sequence:
;		ifid = nearest_fid(testfid, fids)
;	Input:
;		testfid		fileid in the format of yymmdd.hhmm
;		fids		list of file ids
;	Return:
;		the index of the nearest file id.
;
;	History: written 6-May-94...
;-
;	----------------------------------------------------------------

	if (strpos(fidslst(0),'_',0) ne -1) then begin	;1st is weekly
	  fids = fidslst(1:*)
	  weekly =1
	endif else begin
	  fids = fidslst			;all are ok
	  weekly =0
	endelse

	hit = where(fids eq tfid, nhits)
	if (nhits gt 1) then begin
	  ret = hit(0)		;pass the 1st hit back
	endif else begin
	  low = where(fids lt tfid, nlow)
	  if (nlow gt 1) then low = low(nlow-1)	;nearest low

	  high= where(fids gt tfid, nhigh)
	  if (nhigh gt 1) then high = high(0)	;nearest high

	  deltasec = int2secarr(fid2ex([fids(low(0)),fids(high(0))]),fid2ex(tfid))
          nearesti = where(abs(deltasec) eq min(abs(deltasec)))
          if (nearesti(0)) then begin
	    ret = high			;got index=1 or high val.
	  endif else ret = low		;got index=0 or low val.
	endelse

	if (weekly) then ret = ret +1
	return, ret
	end	
