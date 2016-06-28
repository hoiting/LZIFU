pro merge_genxcat, indir, outdir, _extra=_extra, $
    year=year, month=month, day=day, debug=debug, replace=replace
;+
;
;   Name: merge_genxcat
;
;   Purpose: merge multiple genx catalogs -> fewer (reduce granularity)
;
;   Input Parameters:
;      indir -  input path for existing catalogs - 
;      outdir - desired output for merged catalogs -
;
;   Keyword Parameters
;      year - if set, granularity = 1 catalog per year
;      month - if set, granularity = 1 cat/month
;      day - if set, granularity = 1 cat/day
;
;   Restrictions:
;      Currently assumes catalog names nnnn...YYYYMMDD_HHMM..NExxx....gen{x,y}
;      (ie, written via write_genxcat with /NELEMENTS switch set
;
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-

debug=keyword_set(debug)
if keyword_set(replace) and 1-data_chk(outdir,/string) then $
   outdir=indir

if not data_chk(indir,/string) then begin 
   box_messaage, 'Need to supply input path'
   return
endif

files=file_list(indir,'*_NE*.gen*')

if files(0) eq '' then begin 
   box_message,'No genx catalog files found...'
   return
endif

break_file,files,ll,pp,ff,vv,ee

fids=extract_fids(ff)
nelem=str2number(ssw_strsplit(ff,'NE',/tail))

case 1 of 
   keyword_set(year):  nchar=4
   keyword_set(month): nchar=6
   keyword_set(day):   nchar=8
   else: begin
      box_message,['Please set on of the time granularity keywords', $
                   'IDL> merge_genxcat,indir,outdir [,/YEAR] [,/MONTH] [,/DAY]']
      return
   endcase
endcase

gpatt=strmid(fids,0,nchar)    
upat = uniq(gpatt)

; get a template record
restgen,file=files(0),catrec
temprec=catrec(0)

prefix=strmid(ff(0),0,strpos(ff(0),fids(0)))

for i=0,n_elements(upat)-1 do begin 
   catss=where(gpatt eq gpatt(upat(i)),sscnt)
   box_message,'Merging ' + strtrim(sscnt,2) + ' catalog files'
   totne=total(nelem(catss))               ; total records new catalog 
   newrec=replicate(temprec,totne)         ; 
   pnts=[0,totvect(nelem(catss))]
   for j=0,sscnt-1 do begin 
      restgen,file=files(catss(j)),catrecs
      newrec(pnts(j))=catrecs
   endfor
   if debug then stop,'prior to write'
   write_genxcat, newrec, topdir=outdir, /nelements, _extra=_extra, prefix=prefix
endfor

end
