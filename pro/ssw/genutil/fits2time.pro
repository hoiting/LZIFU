function fits2time, header, fid=fid, $
   	soho=soho, kp=kp
;+
;   Name: fits2time
;
;   Purpose: convert fits header times to Yohkoh convention
;
;   Input Parameters:
;      header - fits header or fits file name array
;
;   Keyword Parameters:
;      soho - switch, if set, fits header is SOHO time convention
;        kp - switch, if set, fits uses KittPeak time convention
;
;   History:
;      25-oct-1994 (SLF) Proto written
;       8-Feb-1995 (SLF) update KP option#2
;      25-sep-1995 (SLF) MSO-like option
;-
case 1 of 
   strpos(strupcase(strtrim(header(0),2)),'SIMPLE') eq 0: begin
      message,/info,"Fits header..."
      head=header
   endcase 
   file_exist(header(0)): begin
      mesage,/info,"File name input..."
      dat=rfits2(header(0),head=head)
   endcase
   else: begin
      message,/info,"Input must be FITS header or fits filename array...
      return,0
   endcase
endcase

; determine time algorithim by type (use fits ORIGIN field)
origin=fxpar(head,'ORIGIN')
sohotype=['EIT','LASCO','CDS','SOI-MDI']  ; add to list to extend SOHO convention
kptype=['KPNO-IRAF']			  ; add to list for KP convention

kpcase=is_member(origin,kptype)		; first case was KPeak
sohocase=is_member(origin,sohotype)

; define common fits time fields 
obstime=fxpar(head,'OBS_TIME')
utstart=fxpar(head,'UTSTART')
obsdate=fxpar(head,'OBS_DATE')
startime=fxpar(head,'STARTIME')

tarr=anytim2ex('1-jan-79')

; now apply algorithm based on 'type'
case 1 of
   kpcase: begin
;     handle KP time conventions ( 2 methods known)
      if obstime ne 0 then begin 
         time = obstime*1000L
         tarr = anytim2ex( [time, 0] )
      endif else begin
         ss = where(strmid(head,0,7) eq 'UTSTART')
         tarr = anytim2ex(strmid(head(ss(0)), 11, 8))
      endelse

      if obsdate ne 0 then begin 
         yymmdd=intarr(3)
         reads,string(strtrim(obsdate,2),format='(a6)'),yymmdd,format='(3i2)'
         tarr(4)=yymmdd([1,0,2])
      endif else begin
         a = long(startime)
         b = long(a/86400.) - 3286		;convert to days past 1-Jan-79
         tarr0 = anytim2ex([0,b])
         tarr(4:6) = tarr0(4:6)
      endelse
   endcase

   sohocase: begin
      message,/info,"soho case..."
   endcase   
   else: begin
;     Try the "MEES" standard
      year=fxpar(head,'YEAR')
      mnt=fxpar(head,'MONTH')
      day=fxpar(head,'DAY')
      hour=fxpar(head,'HOUR')
      min=fxpar(head,'MINUTE')
      sec=fxpar(head,'SECOND')
      if total(fix([year,mnt,day,hour,min,sec])) gt 0 then begin
         tarr=[hour,min,sec,0,day,mnt,year]
      endif else message,/info,"Unrecognized
   endcase
;
endcase

fid = ex2fid(tarr)
return, fmt_tim(tarr)

end

