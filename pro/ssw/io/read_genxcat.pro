pro read_genxcat, t0x, t1x, outdata, count=count, topdir=topdir, genfiles=genfiles, $
		initialize=initialize, sublevel=sublevel, debug=debug, fast=fast, $
	        dbfiles=dbfiles, catfiles=catfiles, deltat=deltat, status=status, loud=loud, error=error
;
;+   Name: rd_genxcat
;
;    Purpose: read a catalog which uses 'genx' (or 'geny') format files
;
;    Input Parameters:
;      t0 - start time for search
;      t1 - stop time for search
;
;    Output Parameters:
;      outdata - output catalog data between t0 and t1
;
;    Keyword Parameters:
;      TOPDIR - parent directories where catalogs reside
;      STATUS - success status 1=success=records between t0,t1
;      DELTAT - output - deltaT seconds between t0 and output
;      COUNT  - output - number of output records returned  
;      ERROR - output - (boolean) if set, problem with at least one restgen
;  
;    History:
;      9-Mar-1998 - S.L.Freeland - long planned 'gen' function
;                   finally implemented for TRACE  
;     23-Apr-1998 - dont clobber input (t0x,t1x)
;                   handle last file properly when no times are passed
;     15-Jun-1998 - S.L.Freeland - use another 'temporary' call
;     25-Jun-1998 - S.L.Freeland - protect against no data between t0,t1
;                   add DELTAT , STATUS, and COUNT keywords
;     19-Jul-1998 - S.L.Freeland - pre make array instead of concatenation
;      4-Aug-1998 - S.L.Freeland - copy_struct -> template (allow diff structs)
;     10-Sep-1998 - S.L.Freeland - use file name NEXXX (number of structures)
;                                  to presize output if available
;     11-sep-1998 - S.L.Freeland - call 'rd_genx' directly with /FAST switch
;      7-Nov-1998 - S.L.Freeland - define catfiles from common if possible
;     11-Nov-1998 - S.L.Freeland - increased backward look to (look at
;                                  maximum fid dtime (catalog "cadence")
;     16-dec-1998 - S.L.Freeland - fix cadence bug (when /init not set)
;     11-aug-1999 - S.L.Freeland - permit catalogs without binary format
;                                  (ex: date_obs only)
;      2-dec-1999 - R.D.Bentley  - Took out the hardwired LOUD
;     13-mar-2000 - S.L.Freeland - allow 'time/mjd'
;      2-May-2000 - S.L.Freeland - limit number of files to backup
;     15-Jan-2002 - S.L.Freeland - extend to 'geny' catalogs
;     20-Mar-2002 - S.L.Freeland - allow GENY to have different anonymous structures
;     24-Mar-2002 - L.W.Acton - Changed "for" variables to longword type
;     19-Feb-2004 - S.L.Freeland - protect against "missing" files
;                                  (may occur if catalog regenerated in-situ
;                                   and update occurs between reads...)
;  
;    Restrictions:
;       catalog files have GMT of first record embedded in file name
;
;    Calls:
;       file2time, time2file, restgen, restgenx, rd_genx
;-
common read_genxcat_blk1, last_topdir, cfiles, cfids
common read_genxcat_blk2, catcadence
common read_genxcat_blk3, cftimes                          ; file times

debug=keyword_set(debug)
loud=keyword_set(loud)

if data_chk(topdir,/string,/scalar) then begin
     if file_exist(topdir) then tdir=topdir else tdir=get_logenv(topdir)
  endif else tdir=curdir()

if n_elements(last_topdir) eq 0 then last_topdir=''

initialize=keyword_set(initialize) or n_elements(cfiles) eq 0 or $
    last_topdir ne tdir 

if initialize then begin
   if n_elements(sublevel) eq 0 then sublevel=0
   for i=0,sublevel-1 do tdir=concat_dir(tdir,'*')
   catfiles=file_list(tdir,'*_NE*.gen*',/cd)
   if catfiles(0) eq '' then catfiles=file_list(tdir,'*.gen*',/cd)
   cfiles=catfiles
   cfids=extract_fid(cfiles)
   cftimes=file2time(cfids,out='sec')
   if n_elements(ctimes) eq 1 then cftimes=[0,cftimes]
   last_topdir=tdir
endif else if n_elements(catfiles) eq 0 then catfiles=cfiles

nfiles=n_elements(cfiles)

fiddelim=(['.','_'])(strpos(cfids(0),'_') ne -1)

if n_elements(t0x) gt 0 then t0=anytim(t0x,/int) else $
         t0=file2time(cfiles(0),out='int')

if n_elements(t1x) gt 0 then t1=anytim(t1x,/int) else $
         t1=timegrid(file2time(last_nelem(cfiles)),/day,out='int')

dt0=ssw_deltat(cftimes,ref=t0)
dt1=ssw_deltat(cftimes,ref=t1)

ss0=where(dt0 ge 0,s0cnt)>0
if s0cnt eq 0 then ss0=where(dt0 eq max(dt0))

ss1=where(dt1 le 0,s1cnt)<nfiles

if last_nelem(ss1) eq -1 then ss1=ss0(0)+1

if ss0(0) gt 0 then ss0=[ss0(0)-1,ss0] 

nok=last_nelem(ss1) - ss0(0) 

if nok lt 0 then begin 
   message,/cont,'no good catalogs...'
   return
endif

ss=indgen(nok+1) + ss0(0)
sscnt=n_elements(ss)
if debug then stop,'check ss'

geny=strpos(catfiles(ss(0)),'.geny') ne -1
if geny then restgenx,file=catfiles(ss(0)),outdata else $
   rd_genx, catfiles(ss(0)), outdata,/fast
nepattern='_NE'
break_file,catfiles(ss),ll,pp,ff,ee,xx
ssroots=ff+ee

estring=(['rd_genx,catfiles(ss(i)), temp,/fast', $
          'restgenx,file=catfiles(ss(i)), temp'])(strpos(catfiles(ss(0)),'.geny') ne -1)

error=0    ; somewhat optimistically, initialize to no error 
if strpos(catfiles(ss(0)),nepattern) ne -1 then begin 
   if loud then box_message,'Using embedded NELEMENTS...
   nelems=strextract(catfiles(ss),nepattern,'.gen')
   nout=[0,long(nelems)]
   point=totvect(nout)
   if loud then box_message,'Pre creating output array...'
   outdata=replicate(outdata(0),total(nout))
   if loud then box_message,'Reading data...'
 
   for i=0L,sscnt-1 do begin
      if loud then print,'Reading:>> ' + ssroots(i)
      delvarx,temp
      estat=execute(estring) 
      rdok=data_chk(temp,/struct) 
      error=error or (1-rdok)
      if rdok then outdata(point(i))=str_copy_tags(outdata(0),temp)
   endfor
endif else begin 
   for i=1L,sscnt-1 do begin
      if loud then print,'Reading:>> ' + ssroots(i)
      delvarx,temp
      estat=execute(estring)
      rdok=data_chk(temp,/struct) 
      error=error or (1-rdok)
      if rdok then outdata=[temporary(outdata),temporary(temp)]
   endfor
endelse

; trim times to actual if supplied
if n_elements(t1) gt 0 then begin
   case 1 of
      required_tags(outdata,'time,day'): temptimes=anytim(outdata,/ints)
      required_tags(outdata,'time,mjd'): temptimes=anytim(outdata,/ints)
      required_tags(outdata,'date_obs'): temptimes=anytim(outdata.date_obs,/ints)
      else:begin
	 box_message,'Unexpected SSW TIMES, - cannot trim times'
	 ss=-2
         return
      endcase
    endcase
    ss=sel_timrange(temptimes,t0,t1,/between)

    if ss(0) eq -1 then begin 
      ss=tim2dset(temptimes,t0,delta=deltat)
      box_message,['No times between t0 and t1, returning record closest to t0', $
        'DeltaT (catrec,t0) = ' + strtrim(deltat,2) + ' seconds']
   endif
   outdata=outdata(ss)
endif

status=n_elements(deltat) eq 0

count=n_elements(outdata)

return
end
