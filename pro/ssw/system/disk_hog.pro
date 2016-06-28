pro disk_hog, path, outarr=outarr, hc=hc, mailcutoff=mailcutoff
;+
;   Name: disk_hog
;
;   Purpose: show disk usage, order by size
;
;   Input Parameters:
;      path - if set, path for summary search (default is local user area)
;
;   Calling Sequence:
;      disk_hog [,path] [/hc]
;
;   History:
;      Circa 1-jan-1995 (SLF)
;      20-dec-1995 (SLF) fix KB option for OSF
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-
if n_params() eq 0 then p=ssw_strsplit(get_logenv('HOME'),'/',head=path,/tail)

; --------- do the summary usage listing --------------
pushd,curdir()
cd,(path)(0)
tempf='$HOME/dulist'

cmd='du -s' + (['','k'])(is_member(!version.os,['OSF'])) + ' * > ' + tempf
message,/info,"Looking at files under: " + path(0)
spawn,cmd
cols=rd_tfile(tempf,2)
total=total(float(cols(0,*)))/1.024e3
popd
if cols(0) eq '' then return
; ---------------------------------------------------
dat=rd_tfile(tempf,2)
ss=reverse(sort(long(dat(0,*))))		; decreasing order

outbuf=strjustify(['disk_hog run : ' + ut_time(/to_local), '', 'Node: ' + $
   get_host(/short), 'Path: ' + (path)(0),		$
   strjustify(["Total:     " + string(total,format='(F8.3)') + "  Mb"]),'',  $
   strjustify(reform(dat(1,ss))) + '  '    + $
   strjustify(reform(dat(0,ss)))+'  Kb'],/box)
; -----------------------------------

prstr,outbuf
outarr=outbuf
if keyword_set(hc) then prstr,outbuf,/hc

file_delete,tempf
return
end
