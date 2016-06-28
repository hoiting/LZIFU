function timeavg, intimes, tag,  bin=bin, center=center, start=start, $
	nsamps=nsamps, loud=loud, filldata=filldata
;+
;   Name: timeavg
;
;   Purpose: sum & average data values, 
;
;   Input Parameters:
;      intimes - input (assume yohkoh data structure)
;      tag - string tag name or integer (tag index), scaler or array
;
;   Output:
;      function returns structure with standard Yohkoh structure format
;
;   Optional Keyword:
;      bin    -  (in)  bin width in seconds (integration time)
;      center -  (in)  switch, if set, time is bin center  (default)
;      start  -  (in)  switch, if set, time is bin start
;      alltags - (in)  switch, if set, average all vector tags
;      nsamp  - (out) lonarr, number of valid samples per summed time
;
;   Calling Sequence:
;      outstr=timeavg(instr [,tagarray, bin=bin, /alltags, nsamp=nsamp] )
;
;   Calling Examples:
;      rd_gxd, t0, t1, goesdata		       ; read 3 second goes data
;      onemin=timeavg(goesdata)		       ; 1min avgs,all 1D tags (default)
;      fivemin=timeavg(goesdata,'lo',bin=300.) ; 5min avgs,lo channel only
;      (illustration for goes 3 second data averaging)   
;      IDL> help,goesdata,onemin,fivemin
;         GOESDATA        STRUCT    = -> GXD_DATA_REC Array(1176)
;         ONEMIN          STRUCT    = -> MS_159127700002 Array(59)
;         FIVEMIN         STRUCT    = -> MS_159127700002 Array(13)
;      IDL> help,onemin,fivemin,/str
;         ** Structure MS_159127700002, 4 tags, length=16:
;         TIME            LONG          50402212
;         DAY             INT           5146
;         LO              FLOAT       1.57314e-06
;         HI              FLOAT       5.15764e-08
;         ** Structure MS_159138295005, 3 tags, length=12:
;         TIME            LONG          50402212
;         DAY             INT           5146
;         LO              FLOAT       1.55500e-06
;
;   History:
;      10-Jan-1995 (SLF) dusted off / revamped avg_data.pro 
;      13-Jan-1995 (SLF) fix problem with tag subset
;       2-sep-1995 (SLF) protect against outgrid has 1 elements
;
;   Restrictions:
;      maybe good to 1 second or so, maybe plus or minus I think.
;-
; --------------------------------------------------------------------
loud=keyword_set(loud)
; check input valididy - return on invalid
if not data_chk(intimes,/struct) then begin
   tbeep
   message,/info,'Input times must be structure, returning...'
   return, intimes
endif

grid=intimes

tagnames=tag_names(intimes)
include=rem_elem(tagnames,['TIME','DAY'],rcnt)	; dont average time fields!

if rcnt eq 0 then message,"Input structure contains no fields to average"

; if no tags specified, pick off all 1D tags
if n_elements(tag) eq 0 then begin
   tag=include(0)   
   for i=1,rcnt-1 do if data_chk(intimes.(include(i)),/ndimen) eq 1 then $
      tag=[tag,include(i)]
   if loud then message,/info,"Averaging Tags: " + arr2str(tagnames(tag))
endif

case data_chk(tag,/type) of		; tag may be name (string) or index
   7: tags=tag_index(grid,tag)
   0: begin
        message,/info,'Specify tag name, tag index, or use /alltag switch..."
        return,grid
      endcase
   else: tags=tag
endcase   
; --------------------------------------------------------------------
if n_elements(bin) eq 0 then bin=60.	; default is 1 minute average
; --------------------------------------------------------------------
secs=int2secarr(grid)					; seconds 
if not keyword_set(start) then secs=secs+(bin/2)	; timetag=bin center
last=n_elements(grid)-1					; pointer last element
binsize=min(deriv_arr(secs)>1)				; minimum seperation
sampsize=round(bin/binsize)

;--------- form 'ideal' time grid (granularity=minimum seperation) ---------
if not keyword_set(filldata) then filldata = -9999l
deltat=round(secs(last)-secs(0))			; full time range
nsamp=round(deltat/binsize)				;
deficit= sampsize - (nsamp mod sampsize)		; pad range to binsize
tideal=fltarr(nsamp + round(deficit)) + filldata	; dummy data fill
ngrid=n_elements(tideal)
ss=round(secs/binsize)<(ngrid-1)			; reformed bin pointers
nsamp=ngrid/sampsize
; -----------------------------------------------------------------
; get gridtimes (Yohkoh internal fmt)
newtgrid=timegrid(grid(0),nsamp=nsamp,seconds=binsize*sampsize)
;
; --------------------- build output structure -------------------
newstr='{dummy,time:0L, day:0'			; standard time definition
for i=0,n_elements(tags)-1 do newstr=newstr + ',' + tagnames(tags(i)) + ':0.0'
outstr=replicate(make_str(newstr + '}'),nsamp)
outstr.time=newtgrid.time				; copy times to output
outstr.day =newtgrid.day
; ------------------------------------------------------------------


; --------------------- average specified 1D tags --------------------
samparr=make_array(sampsize,nsamp,/long)		; sample count array

for i=0,n_elements(tags)-1 do begin			; for each TAG
   tideal(ss)=intimes.(tags(i))				; bin the 1D data 
   newgrid=reform(tideal,sampsize,nsamp)		; reform it
   samparr(*)=0l					; initialize samp count
;  logic to differentiate missing data from zero data
   goodsamp=where(newgrid ne filldata,gcnt)		; good samples
   badsamp= where(newgrid eq filldata,bcnt)		; bad (missing)
   if gcnt gt 0 then samparr(goodsamp) =1		; good sample arrary
   if bcnt gt 0 then newgrid(badsamp)  =0		; zero bad data array
   nsamps=total(samparr,1)				; n samples per bin
   if n_elements(outstr) eq 1 then $
      outstr.(tag_index(outstr,tagnames(tags(i)))) = $
         (total(newgrid,1)  / (nsamps > 1))(0) else  $  		; average array
      outstr.(tag_index(outstr,tagnames(tags(i)))) = $	; tagindex <-> old index
         total(newgrid,1)  / (nsamps > 1)  		; average array
endfor

; ----------- delete records where no samples were found ------------
good=where(nsamps,gcnt)					
if gcnt gt 0 then begin
   nsamps=nsamps(good)
   outstr=temporary(outstr(good)) 
endif
; ---------------------------------------------------------------

return, outstr
end

