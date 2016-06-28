pro write_genxcat, structures, topdir=topdir, weeksub=weeksub, $
		   prefix=prefix, text=text, catname=catname, $
                   day_round=day_round, hour_round=hour_round, $
                   nelements=nelements, delete_time=delete_time, $
                   no_delete_time=no_delete_time, geny=geny, _extra=_extra
;
;+  Name: write_genxcat
;
;   Purpose: write one 'catlog' in genx/geny format (read by read_genxcat)
;
;   Input Parameters:
;      structures - structures to write to catalog
;  
;   Keyword Parameters:
;      topdir  -  optional parent diretory for output (catalog) files
;      text - optional string or string array text descriptor to include
;      weeksub - if set, prepend weekly subdirectory to output path
;      prefix  - if supplied, optional prefix (prepend to first struct. GMT)
;      catname - optional fully defined name for output (.genx added)  
;      day_round -  round output file name to : ...yyyymmdd.0000
;      hour_round - round output file name to:  ...yyyymmdd.hh00
;      nelements=nelements - if set, include number structures in name
;                            fomat= ...yyyymmdd_hhmm_NExxxx'
;      no_delete_time - if /nelements is set and there are already files
;                       with identical time stamps, the default is to 
;                       remove them before writing the new file - this
;                       keyword overrides that behavior 
;      geny - if set, use 'savegenx' instead of 'savgen' (.geny instead of .genx)
;      _extra - passed to savse routine via inheritance
;
;   Restrictions:
;     input structures must include an SSW standard time field 
;
;   History:
;       10-March-1998 - S.L.Freeland
;       10-Sep-1998   - S.L.Freeland - add /DAY_ROUND, /HOUR_ROUND, /NELEMENTS
;       15-sep-1998   - S.L.Freeland - add /DELETE_TIME
;       15-Jan-2002   - S.L.FReeland - add /GENY keyword and function
;-

geny=keyword_set(geny)

case 1 of
   required_tags(structures,'day,time'): fname=time2file(structures(0))
   required_tags(structures,'mjd,time'): fname=time2file(structures(0))
   required_tags(structures,'date_obs'): $
         fname=time2file( anytim(gt_tagval(structures(0),/date_obs) ,/ints))
      else: begin
         box_message,'Required tags ' + arr2str([missing1,missing2]) +' are missing'
         return
     endcase
endcase

case 1 of 
   keyword_set(hour_round): zchar=2
   keyword_set(day_round):  zchar=4
   else:
endcase

if data_chk(zchar,/scalar) then begin
  fname0=fname
  fname=strmid(fname,0,strlen(fname)-zchar) + arr2str(replicate('0',zchar),'')  
  box_message,['Rounding file name...', 'From:'+fname0,'To:  '+fname]
endif

if data_chk(catname,/string) then fname=catname(0)  ; override with user supplied

itext='Written by <write_genxcat> at ' + systime()
case 1 of
    data_chk(text,/string): itext=[text,itext]
    else:
endcase

if not data_chk(topdir,/string) then topdir=curdir()
if keyword_set(weeksub) then $
    topdir=concat_dir(topdir,'week'+anytim2weekinfo(structures(0),/first))

if not data_chk(prefix,/string) then prefix=''
if not data_chk(catname,/string) then catname=concat_dir(topdir,prefix+fname)
delete_time=1-keyword_set(no_delete_time)
if keyword_set(nelements) then begin
   if delete_time then begin 
      exist_names=findfile(catname+'_NE*.gen' + (['x','y'])(geny))
      if exist_names(0) ne '' then begin
         box_message,['Removing files prior to writing:',exist_names]
         file_delete,exist_names
      endif
   endif
   catname=catname+'_NE'+strtrim(n_elements(structures),2)
endif

case 1 of 
   keyword_set(geny): savegenx, structures, file=catname, _extra=_extra
   else: savegen, structures, file=catname, text=itext               ; write catalog
endcase

return
end


