function rfits,filnam,index=fnum,date_obs=date,time_obs=time, $
         header=head,scale=scale, qstop=qstop, nodata=nodata

;+
; NAME:
;        RFITS
; PURPOSE:
;        Reads a standard FITS disk file into an array.
; CATEGORY:
;        Input/Output.
; CALLING SEQUENCE:
;        result = rfits(filename)
; INPUTS:
;        filename = string containing the file name.
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;        index = nonnegative integer. If this parameter is present, a period
;              and the index number are appended to the filename (e.g., '.34').
;              This option makes handling of data in the MCCD file naming
;              convention easier.
;        scale = if set, floating point array is returned, reflecting
;                that true value = read value * bscale + bzero.
;	 nodata = If set, then just read the headers
; OUTPUTS:
;        result = byte, integer, or long array, containing the FITS data array.
;               The dimensionality of result reflects the structure of the FITS
;               data.  If keyword scale is set, then floating point array.
; OPTIONAL (KEYWORD) OUTPUT PARAMETERS:
;        date_obs = date of observation (string).
;        time_obs = time of observation (string).
;        header = string vector, containing the full FITS header (each element
;                 of the vector contains one FITS keyword parameter).
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
;        None.
; RESTRICTIONS:
;        Only simple FITS files are read. FITS extensions (e.g., groups and
;        tables) are not supported.
; MODIFICATION HISTORY:
;        JPW, Nov, 1989.
;        nn, jan, 1992, to add the option to return array containing
;                       true values calculated from bscale and bzero.
;	MDM (16-Sep-92) - Added code to do byte swapping when the output
;			  array is integer*2 or integer*4 and reading on a
;			  DEC machine.
;	MDM (16-May-93) - Expanded to handle REAL*4 and REAL*8 data types.
;	MDM (27-Jan-94) - Corrected so that it could handle long 1 dimensional
;			  arrays (replaced FIX with LONG)
;       DMZ (6-Apr-94)  - added DEC/OSF check
;	SLF (7-Apr-94)  - fixed typo
;	MDM (13-Oct-95) - Added /QSTOP
;			- Allowed NAXIS = 0 and not crash the reader
;	MDM (22-Aug-96) - Added /nodata
;       AAP (19-Feb-98) - Added 'linux' to the swap_os
;       SLF (19-Feb-98) - call 'is_lendian' (single point 'swap_os' function)
;-

; open FITS file

if n_elements(fnum) ne 0 then file = filnam+'.'+string(format='(i0)',fnum) $
   else file = filnam
get_lun,unit
openr,unit,file

; read the header

head = ''
repeat begin
   h = bytarr(80,36)
   readu,unit,h
   h = string(h)
   if n_elements(head) lt 36 then head=h else head=[head,h]
   flag = 0
   for i=0,35 do if strmid(h(i),0,8) eq 'END     ' then flag = 1
endrep until flag eq 1
nh = n_elements(head) - 1

; get the keywords

; search BITPIX keyword
i = -1
repeat i=i+1 until (strmid(head(i),0,8) eq 'BITPIX  ') or (i eq nh)
if i eq nh then begin
   print,'error: keyword BITPIX not found '
   goto,done
endif
bitpix = fix(strmid(head(i),10,20)) 
; search NAXIS keyword
i = -1
repeat i=i+1 until (strmid(head(i),0,8) eq 'NAXIS   ') or (i eq nh)
if i eq nh then begin
   print,'error: keyword NAXIS not found '
   goto,done
endif
naxis = fix(strmid(head(i),10,20))
; search NAXISi keywords
for j=1,naxis do begin
   i = -1
   repeat i=i+1 until $
     (strmid(head(i),0,8) eq 'NAXIS'+string(format='(i1)',j)+'  ') or (i eq nh)
   if i eq nh then begin
      print,'error: keyword NAXIS',j,' not found '
      goto,done
   endif
   if n_elements(nxi) eq 0 then nxi = long(strmid(head(i),10,20)) $
                          else nxi = [nxi,long(strmid(head(i),10,20))]
endfor
; search DATE-OBS keyword
i = -1
repeat i=i+1 until (strmid(head(i),0,8) eq 'DATE-OBS') or (i eq nh)
if i eq nh then date = ' 0/ 0/ 0' else begin
   date = strtrim(strmid(head(i),10,20),2)
   j = strlen(date)
   date = strmid(date,1,j-2)
endelse
; search TIME-OBS keyword
i = -1
repeat i=i+1 until (strmid(head(i),0,8) eq 'TIME-OBS') or (i eq nh)
if i eq nh then time = ' 0: 0: 0' else begin
   time = strtrim(strmid(head(i),10,20),2)
   j = strlen(time)
   time = strmid(time,1,j-2)
endelse

; create data array, and read it

data = 0b
if (naxis eq 0) then goto,done		;MDM added 13-Oct-95
if (keyword_set(nodata)) then goto,done	;MDM added 22-Aug-96

expr = ''
for i=0,naxis-1 do expr = expr+'nxi('+string(format='(i1)',i)+'),'
case bitpix of
   8 : expr = 'data=bytarr('+expr+'/nozero)'
  16 : expr = 'data=intarr('+expr+'/nozero)'
  32 : expr = 'data=lonarr('+expr+'/nozero)'
  -32: expr = 'data=fltarr('+expr+'/nozero)'	;MDM added 16-May-93
  -64: expr = 'data=dblarr('+expr+'/nozero)'	;MDM added 16-May-93
  else : begin
         print,'invalid BITPIX keyword     BITPIX=',bitpix 
         goto,done
  endelse
endcase
flag = execute(expr)
if flag eq 0 then begin
   print,'error during array allocation '
   goto,done
endif
readu,unit,data

;FITS format standard is not the convention used by DEC
qswap=is_lendian()

if ((qswap) and (abs(bitpix) gt 8)) then dec2sun, data
if ((!version.os eq 'vms') and (bitpix lt 0)) then yoh_ieee2vax, data	;MDM added 16-May-93
;
; return scaled array ?
if keyword_set(scale) then begin
   i = -1
   repeat i=i+1 until (strmid(head(i),0,6) eq 'BSCALE') or (i eq nh)
   if i eq nh then begin
      bscale=1.
      print,'bscale parameter not found,  set to 1.0' 
   endif else begin
      bscale = float(strmid(head(i),10,20))
   endelse

   i = -1
   repeat i=i+1 until (strmid(head(i),0,5) eq 'BZERO') or (i eq nh)
   if i eq nh then begin
      bzero=0.
      print,'bzero parameter not found,  set to 0.0'
   endif else begin
      bzero = float(strmid(head(i),10,20))
   endelse

   data_dum=float(data)
   data_dum=float(data)*bscale+bzero
   data=data_dum

endif

done: free_lun,unit
if (keyword_set(qstop)) then stop
return,data
end


