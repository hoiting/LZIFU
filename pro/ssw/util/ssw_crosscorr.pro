;+
; Project     : SDAC
;                   
; Name        : SSW_CROSSCORR 
;               
; Purpose     : This procedure computes a crosscorrelation function between two
;		time series.
;               
; Category    : MATH
;               
; Explanation : 
;		using the IDL function R=CORRELATE(xx,yy)
;		R=TOTAL(xx*yy)/SQRT(TOTAL(xx^2)*TOTAL(yy^2))
;		r0 and r1 are two arrays of equal length 
;               
; Use         : CROSSCORR, R0, R1, CC, II, NPIX
;		crosscorrelation function CC(R0,R1) with time delay -NPIX<II<NPIX
;
; Inputs      : R0 - first time series
;		R1 - second time series, same length as R0, same time bins
;		NPIX - half-width of crosscorrelation interval, in bin units of R0               
; Opt. Inputs : None
;               
; Outputs     : CC - Crosscorrelation function vs lag.
;		II - lag in units of bins of R0 and R1
; Opt. Outputs: None
;               
; Keywords    : 
;
; Calls       :
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  :
;		created by M.Aschwanden, March 1995
; Modified    : 
;		Version 2, RAS, documented added to SDAC tree 6-jan-1997
;		Version 3, RAS, fixed bugs, 26-mar-1997
;		14-jun-2001, renamed from crosscorr to prevent conflict, RAS
;-            
;==============================================================================
pro ssw_crosscorr,r0,r1,cc,ii,npix

nr	=n_elements(r0)
nr2	=n_elements(r1)
checkvar, npix, nr-2
if (nr ne nr2) then begin
	help, r0, r1
	message,'R0 and R1 must have equal lengths'
	endif
if (npix ge nr-1) then npix=nr-2
n	=2*npix+1
cc	=fltarr(n) 
ii	=fltarr(n)
for i=-npix,npix do begin
 if (i le 0) then begin 
	r0i=r0(0:nr-1+i) 
	r1i=r1(-i:nr-1)   
 	endif
 if (i gt 0) then begin
 	r0i=r0(i:nr-1)   
	r1i=r1( 0:nr-1-i) 
 	endif
 cc(i+npix)=correlate(r0i,r1i)
 ii(i+npix)=i
 endfor
end
