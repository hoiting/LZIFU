function grid_data, iindex , $
   seconds=seconds, minutes=minutes, hours=hours, days=days, $
   ss=ss, not_uniq=not_uniq, delta=delta, oindex=oindex, nsamp=nsamp
;+
;   Name: grid_data
;
;   Purpose: return gridded subset of input (~fixed cadence if no gaps)
;
;   Input Parametrs:
;      index - generally, an index or roadmap array - any SSW standard time
;
;   Keyword Parameters:
;      seconds, hours, minutes, days (one) - desired cadence passed to timegrid.pro
;      non_uniq - if set, return duplicates (default is uniq matches)
;      oindex -   if set, return index(SS) - default is subscripts (SS)
;      delta (output) - delta seconds for data set/grid matches
;
;   Output Parameters:
;      function returns SS vector of index records closest to grid times
;      if /OINDEX is set, return INDEX(SS); ie, reduced structure array
;
;   Calling Examples:
;      gdata=grid_data(index, min=5)	       ;return SS vector, cad.=5minutes
;      gdata=grid_data(rmap, hour=6],/oindex)  ;return index(SS), cad.= 6 hours
;      evt_grid,grid_data(rmap,min=5,/oindex,tickpos=.9)  ; overlay on utplot
;
;   Method: calls timegrid.pro and tim2dset
;
;   History:
;      19-may-1995 (S.L.Freeland) - allow tasting (sampling) files at low cadence
;       5-mar-1997 (SLF) -> SSW
;      16-Sep-1998 - S.L.Freeland - add NSAMP and pass->timegrid
;      12-Nov-1998 - S.L.Freeland - put an anytim wrapper on input
;      18-sep-2000 - S.L.Freeland - added DAYS keyword (->timegrid)
;-
if n_params() eq 0 then begin 
   box_messge,['Need input times and (a cadence OR number samples)', $
               'IDL> ss=grid_data(index, [min=mins][hour=hour][nsamp=NN] )']
   return,-1
endif

index=anytim(iindex,/int)             ; standardize input via anytim

s=keyword_set(seconds)
m=keyword_set(minutes)
h=keyword_set(hours)
d=keyword_set(days)

;TODO: default tied to number data elements and/or time seperation  **
if ((s or m or h or d) eq 0) and (1-keyword_set(nsamp)) then begin
   message,/info,"No cadence specified - defaulting to 2. minutes..."
   minutes=2.
endif

not_uniq=keyword_set(not_uniq) or keyword_set(nsamp)

unik=1-not_uniq
ndata=n_elements(index)

; make an evenly spaced grid at user specified granularity via <timegrid.pro>
outgrid=timegrid(index(0),index(ndata-1), nsamp=nsamp, $
   sec=seconds, min=minutes, hour=hours, days=days)

; now match index records sets
ssg=tim2dset(index,outgrid,delta=delta)

if unik then begin
   ussg=uniq(ssg)
   ssg=ssg(ussg)
   delta=delta(ussg)
endif

case 1 of 
   keyword_set(ss): retval=ssg
   keyword_set(oindex): retval=index(ssg)
   else: retval=ssg
endcase

return,retval
end
