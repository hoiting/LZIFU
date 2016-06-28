function file_diff_s1, lun1, lun2, ssmask=ssmask, qdebug=qdebug

fstat = fstat(lun1)
siz = fstat.size
step = 1e+6	;read a meg at a time

qdone = 0
status = 0
while (not qdone) do begin
    point_lun, -1*lun1, p
    nleft = siz-p
    nrd = step < nleft
    if (nleft eq 0) then begin
	qdone = 1
    end else begin
	buff1 = bytarr(nrd)
	readu, lun1, buff1
	buff2 = bytarr(nrd)
	readu, lun2, buff2
	diff = temporary(buff1) - temporary(buff2)
	n = n_elements(diff)
	if (n_elements(ssmask) ne 0) then begin
	    ssmask2 = ssmask-p		;offset into segment
	    ss = where((ssmask2 ge 0) and (ssmask2 le nrd-1), nss)
	    if (nss ne 0) then diff(ssmask2(ss)) = 0
	end
	junk = max(diff)
	qdiff = junk ne 0
	if (qdiff) then begin
	    if (keyword_set(qdebug)) then help, where(diff ne 0)
	    status = 11
	    qdone = 1	;might as well exit -- don't read anymore
	end
    end
    if (keyword_set(qdebug)) then print, p, nleft, nrd, status, qdone
end

return, status
end
;------------------------------------------------------------------
function file_diff, f1, f2, idlpro=idlpro , mess=mess, status=status, $
		binary=binary, ssmask=ssmask, qdebug=qdebug
;+
;   Name: file_diff
;
;   Purpose: check for ascii file difference (boolean)
;
;   Input Parameters:
;      f1, f2 - ascii file names
;
;   Calling Sequence:
;      truth=file_diff(file1, file2 [/idlpro] )
;	truth = file_diff(file1, file2, /binary, ssmask=indgen(2800))
;
;   Keyword Parameters:
;      idlpro - if set, check for header/code differences (";"=comment)
;      mess   - output summary string
;      status - 0=nodiff, >0=diff, [/idlpro only: 2=header , 3=code]
;		[/binary only: 10=file size difference, 11=data difference]
;		-1=files don't exist
;      binary - If set, then do a binary difference
;      ssmask - Optional subscripts of the data portion to ignore (byte positions)
;      
;   History:
;      29-Aug-1996 S.L.Freeland (extracted code from chk_conflict.pro)
;	13-Jul-1998 M.D.Morrison - Added /BINARY option
;	22-Jul-1998 M.D.Morrison - Changed code slightly to make it not
;				   such a memory hog for large files
;	21-Aug-1998 M.D.Morrison - Mod to do large files with piece-meal
;				   reads.
;-

max_comp = 5e+6		;largest file to do a single read compare on

status = -1
if (keyword_set(binary)) then begin	;MDM 13-Jul-98
    if (not file_exist(f1)) then begin
	print, 'FILE_DIFF: Cannot find input file: ' + f1
	return, status
    end
    if (not file_exist(f2)) then begin
	print, 'FILE_DIFF: Cannot find input file: ' + f2
	return, status
    end
    ;
    openr, lun1, f1, /get_lun
    fstat1 = fstat(lun1)
    openr, lun2, f2, /get_lun
    fstat2 = fstat(lun2)
    if (keyword_set(qdebug)) then help, fstat1, fstat2, /str
    if (fstat1.size ne fstat2.size) then begin
	if (keyword_set(qdebug)) then print, 'File sizes differ so the files differ'
	status = 10
    end else begin
	if (fstat1.size ne max_comp) then begin
	    status = file_diff_s1(lun1, lun2, ssmask=ssmask, qdebug=qdebug)
	end else begin
	    buff1 = bytarr(fstat1.size)
	    readu, lun1, buff1
	    buff2 = bytarr(fstat2.size)
	    readu, lun2, buff2
	    diff = temporary(buff1) - temporary(buff2)
	    n = n_elements(diff)
	    if (n_elements(ssmask) ne 0) then diff(ssmask >0<(n-1)) = 0
	    junk = max(diff)
	    qdiff = junk ne 0
	    if (qdiff) then status = 11 else status = 0
	end
    end
    free_lun, lun1
    free_lun, lun2
    return, status
end
;

t1=byte(rd_tfile(f1))
t2=byte(rd_tfile(f2))
chk=where(t1 ne t2, dcnt)
diff=dcnt gt 0 or (n_elements(t1) ne n_elements(t2))
mess=(["No differences","Files are different"])(diff)

status=diff

if diff and keyword_set(idlpro) then begin
   t1=strcompress(strupcase(rd_tfile(f1,nocomment=';',/compress)),/remove)
   t2=strcompress(strupcase(rd_tfile(f2,nocomment=';',/compress)),/remove)
   diffr=where((t1 ne t2) or (n_elements(t1) ne n_elements(t2)),dcnt)
   mess=(["Header difference (only)","Code difference"])(dcnt gt 0)
   status=2+diff
endif

return,diff
end

