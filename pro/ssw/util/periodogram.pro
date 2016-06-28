;+
; Project     : SOHO - CDS     
;                   
; Name        : PERIODOGRAM()
;               
; Purpose     : Calculate periodogram of (unevenly spaced) time series.
;               
; Explanation : Uses method of Horne and Baliuna (Ap.J. 1986) to calculate
;               the periodogram within user-set frequency or period limits 
;               a time series of data.  Data need not be equally spaced in 
;               time.
;
;               eg:
;	        IDL> t = findgen(1000)
;               IDL> x = sin(2.0*!dpi*t/27.0)
;               IDL> power=periodogram(t,x,per=[20,30],npts=100)
;               IDL> plot,power(0,*),power(1,*)
;
;
; Use         : IDL> power = periodogram(time, data,$
;                                 [frequency_range=frequency_range, $
;                                 period_range=period_range, taper=taper,$
;                                 npts=npts])
;    
; Inputs      : time - time values to which values in data correspond.
;               data - data values corresponding to 'time'.
;               
; Opt. Inputs : Either 'freq' or 'period' (see keywords) values must be 
;               specified.
;               
; Outputs     : Function returns a (2,npts) array.
;               array(0,*) = frequency or period array (depends on input given)
;               array(1,*) = periodogram power at returned values of array(0,*)
;               
; Opt. Outputs: None
;               
; Keywords    : freq   - 2 value array giving interval over which to calculate
;                        periodogram, given in frequency.
;               OR
;               period - period values over which to calculate periodogram.
;
;               np     - number of points in calculated periodogram 
;                        (default = number of input data points).
;               taper  - fraction of time series to be tapered to alleviate
;                        end effects. taper=0.25 tapers first and last 25%
;                        (default = 0)
;
;               quiet  - set this to not receive statistical info on screen
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: Not fast for large data sets.
;               
; Side effects: None
;               
; Category    : Util,  numerical
;               
; Prev. Hist. : Original by Judith Lean/John Mariska, NRL.
;
; Written     : Cosmetic CDS version by C D Pike, RAL, 16-Jan-95 
;               
; Modified    : 
;
; Version     : Version 1, 16-Jan-95
;-            

function periodogram, t, x, taper=tp, period_range=period, $
                            frequency_range=frequency, npts=nw, quiet=quiet

;
;  Calculate mean from data and recalculate mean (should now be zero)
;
xx = x
nx=float(N_ELEMENTS(xx))
xx = xx - average(xx) 
avx = average(xx)
varx = total((xx-avx)*(xx-avx))/nx

;
;   Taper time series with TAPER - split-cosine-bell tapering
;
if not keyword_set(tp) then tp = 0.0
LENGTH=MAX(T)-MIN(T)+1
LL=FIX(TP*LENGTH)
IF(TP GT 0.) THEN  BEGIN
   RMIN=WHERE(T LT MIN(T)+LL) & WMIN=FLTARR(N_ELEMENTS(RMIN))
   RMAX=WHERE(T GT MAX(T)-LL) & WMAX=FLTARR(N_ELEMENTS(RMAX))
   FOR M=0,N_ELEMENTS(RMIN)-1 DO WMIN(M)=1-COS((T(RMIN(M))-MIN(T))*!DPI/2/LL)
   FOR M=0,N_ELEMENTS(RMAX)-1 DO WMAX(M)=1-COS((MAX(T)-T(RMAX(M)))*!DPI/2/LL)
   XX(RMIN)=XX(RMIN)*WMIN
   XX(RMAX)=XX(RMAX)*WMAX
ENDIF

;
;  get requested periodogram range into expected units
;
if (not keyword_set(frequency)) and (not keyword_set(period)) then begin
   print,'Error: One of the FREQUENCY_RANGE or PERIOD_RANGE keywords must be given.'
   return,0
endif

if (keyword_set(frequency)) and (keyword_set(period)) then begin
   print,'Error: Only one of the FREQUENCY_RANGE or PERIOD_RANGE keywords must be given.'
   return,0
endif

if keyword_set(frequency) then begin
   if n_elements(frequency) ne 2 then begin
      print,'FREQUENCY_RANGE must be a 2-element variable.'
      return,0
   endif
   w1 = 2.0*!DPI*frequency(0)
   w2 = 2.0*!DPI*frequency(1)
endif else begin
   if n_elements(period) ne 2 then begin
      print,'PERIOD_RANGE must be a 2-element variable.'
      return,0
   endif 
   if period(0) eq 0 or period(1) eq 0 then begin
      print,'One period limit cannot be zero - reset.'
      return,0
   endif
   w1 = 2.0*!DPI/period(0)
   w2 = 2.0*!DPI/period(1)
endelse 

;
;  sort w1 and w2
;
if w1 gt w2 then begin
   temp = w2
   w2 = w1
   w1 = temp
endif


;
;  were number of output points specified?
;
if not keyword_set(nw) then nw = n_elements(x)

;
;  info if not muzzled
;
if not keyword_set(quiet) then begin
   PRINT,'  Number of input points: ',NX
   PRINT,'  Average of input dataset: ',average(x)
   PRINT,'  Variance of input dataset: ',VARX
   print,'  Time range of input = ',max(t)-min(t)
   if keyword_set(tp) then begin
      print,'  First and last ',tp*100,'% of data series tapered.',form='(a,i2,a)'
   endif
   if keyword_set(frequency) then begin
      PRINT,'  Frequency range = ',fmt_vect(frequency)
   endif else begin
      print,'  Period range = ',fmt_vect(period)
   endelse
   PRINT,'  Number of calculated output points: ',NW
endif


;
;   Calculate ta, a and b  (cf. Horne and Baliunus notation)
;
W=FINDGEN(NW)*(W2-W1)/FLOAT(NW)+W1
TA=FLTARR(NW) & A=FLTARR(NW) & B=FLTARR(NW) & C=FLTARR(NW) & S=FLTARR(NW)
FOR K=0,NW-1 DO BEGIN
   TA(K)=ATAN(TOTAL(SIN(2.*W(K)*T))/TOTAL(COS(2.*W(K)*T)))/2./W(K)
   A(K)=1./SQRT(TOTAL(COS(W(K)*(T-TA(K)))*COS(W(K)*(T-TA(K)))))
   B(K)=1./SQRT(TOTAL(SIN(W(K)*(T-TA(K)))*SIN(W(K)*(T-TA(K)))))
   C(K)=A(K)*TOTAL(XX*COS(W(K)*(T-TA(K))))
   S(K)=B(K)*TOTAL(XX*SIN(W(K)*(T-TA(K))))
ENDFOR

;
;   p is normalized to total variance of the entire data set
;
if varx gt 0.0 then P=(C*C+S*S)/2./VARX else P=(C*C+S*S)

;
;  return w to input units
;
if keyword_set(frequency) then begin
   w = w/2.0/!DPI
endif else begin
   w = 2.0*!DPI/w
endelse

;
;  return arrays
;
out = dblarr(2,nw)
out(0,*) = w
out(1,*) = p
return,out

END

