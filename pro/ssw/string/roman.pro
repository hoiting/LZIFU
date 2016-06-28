;
;+
; Project     : SOHO - CDS     
;                   
; Name        : ROMAN()
;               
; Purpose     : Returns ROMAN atomic number given the ionization
;               
; Explanation : 
;
; Use         : name=roman(n)
;    
; Inputs      : Ionization number
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns the ROMAN atomic number
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : CDS Spectral
;               
; Prev. Hist. : None.
;
; Written     : Phil Judge HAO/NCAR, 29 August, 1995
;               
; Modified    : Version 2, 03-Jul-1996, William Thompson, GSFC
;			Corrected bug for values between 27 and 30.
;
; Version     : Version 2, 03-Jul-1996
;-            



FUNCTION roman,i
ionlab=['I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII',$ 
    'XIV','XV','XVI','XVII','XVIII','XIX','XX','XXI','XXII','XXIII','XXIV',$
    'XXV','XXVI','XXVII','XXVIII','XXIX','XXX']
n=n_elements(ionlab)
ii=i
a=size(ii)
if(a(1) eq 0) then return,' '
if(a(1) eq 1) then ii=[ii]
ni=n_elements(ii)
str=strarr(ni)
j=where(ii le n,kount)
if(kount gt 0) then str(j)=ionlab(i(j)-1)
k=where(ii gt n,kount)
if(kount gt 0) then str(k)='>'+ionlab(n-1)
if(ni eq 1) then str=str(0)
return,str
end
