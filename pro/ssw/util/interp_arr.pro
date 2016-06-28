function Interp_arr, img1, img2, Time1, Time2, Time3, $
			unc_img1, unc_img2, unc_arr
;+
; NAME:
;   interp_arr
; PURPOSE:   
;	Linearly interpolate the two input arrays to the requested time.
;
; CALLING SEQUENCE:
;   New_arr = interp_arr(img1 ,img2, Time1, Time2, Time3)
;   New_arr = interp_arr(img1 ,img2, Time1, Time2, Time3, unc_img1, unc_img2, unc_arr)
;
; INPUTS:
;   img1,img2	= Two images that will be linearly interpolated
;   Time1, Time2= The times corresponding to img1, img2 in any standard
;		  Yohkoh standard time format.
;   Time3	= The time to which the returned image should be interpolated
;
; OPTIONAL INPUTS:
;   unc_img1, unc_img2 = uncertainties in img1 and img2, both must be
;   		  passed in if the uncertainty is to be calculated
;
; OPTIONAL OUTPUT:
;   unc_arr = the array of uncertainties in the final image
;
; MODIFICATION HISTORY:
;  9-oct-92, Written, G. A. Linford (and J.R. Lemen)
;  29-sep-95, jmm, Added uncertainty calculation
;  16-apr-2003 jmm, Corrected uncertainty calculation
;-

tt1 = anytim2ex(Time1)
tt2 = anytim2ex(Time2)
tt3 = anytim2ex(Time3)

;	print, 'times 1, 2, 3: ', tt1, tt2, tt3

Dif1 = addtime(tt2,diff=tt1)		; Time2 - Time1
Dif2 = addtime(tt3,diff=tt1)		; Time3 - Time1
; 	print, 'dif1 (tt2-tt1)=', dif1
;	print, 'dif2 (tt3-tt1)=', dif2

If Dif1 eq 0. then begin
  Print, 'Input array times are the same: No interpolation done'
  return, img1
ENDIF
Coef_A = Dif2/Dif1
Coef_B = 1. - Coef_A
IF(n_params() GE 7) THEN $
;  unc_arr = sqrt(coef_a^2*unc_img1^2 + coef_b^2*unc_img2^2) ;jmm, 27-sep-95, corrected 29-sep-95, jmm
  unc_arr = sqrt(coef_b^2*unc_img1^2 + coef_a^2*unc_img2^2) ;jmm, 16-Apr-2003
return,Coef_B*img1 + Coef_A*img2
end
