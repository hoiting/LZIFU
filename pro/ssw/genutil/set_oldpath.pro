pro set_oldpath
;
;+  Name: set_oldpath
;
;   Purpose: incorporate idl version specific directorys in !path
;   	     
;   History: slf, 23-feb-1993
;	     slf, 30-mar-1993 return to caller on error
;            rdb, 16-Aug-94   modified to also run under VMS
;            rdb, 26-Aug-94   moved printe statement inside conditional
;
;   Side Effects:
;      If IDL version is older than ys master, !path may be modified
;
;-
on_error,2

if !version.os eq 'vms' then begin
  oldirs=findfile('$DIR_IDL_OLD:old*.*')
  oldloc=strpos(oldirs,'OLD')
  oldones=where(oldloc ne -1,ocount)
  if ocount gt 0 then begin
;  some $ys/idlfix/oldxxxx  directories are online
    oldloc=oldloc(oldones)
    oldirs=oldirs(oldones)
    for j=0,ocount-1 do begin
      oldirs(j) = strmid(oldirs(j),0,oldloc(j)-1)+'.' $
	+strmid(oldirs(j),oldloc(j),6)+']'
;;      print,oldirs(j)
    endfor

;  reformat into !version.release format for compare	format = x.y.z
     oldrel=strmid(oldirs,oldloc(0)+3,1) + '.' + $
	  strmid(oldirs,oldloc(0)+4,1) + '.' + $
	  strmid(oldirs,oldloc(0)+5,1)
     newer=where(!version.release lt oldrel,dircount)
;     print,!version.release,oldrel,dircount
     if dircount gt 0 then begin
;     required delimiter already in place
        print,'Directories added: ',oldirs(newer)
       !path= arr2str(rotate(oldirs(newer),2),',') + ',' + !path
     endif      
endif

endif else begin
oldirs=findfile(concat_dir('$DIR_IDL_OLD','old*'))
oldloc=strpos(oldirs,'old')
oldones=where(oldloc ne -1,ocount)
if ocount gt 0 then begin
;  some $ys/idlfix/oldxxxx  directories are online
   oldloc=oldloc(oldones)
   oldirs=oldirs(oldones)
;  reformat into !version.release format for compare	format = x.y.z
   oldrel=strmid(oldirs,oldloc(0)+3,1) + '.' + $
	  strmid(oldirs,oldloc(0)+4,1) + '.' + $
	  strmid(oldirs,oldloc(0)+5,1)
   newer=where(!version.release lt oldrel,dircount)
   if dircount gt 0 then begin
;     colon delimiter already in place
      !path= arr2str(rotate(oldirs(newer),2),'') + !path
   endif      
endif
endelse

return
end
