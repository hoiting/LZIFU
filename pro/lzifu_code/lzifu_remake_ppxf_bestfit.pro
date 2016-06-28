FUNCTION lzifu_remake_ppxf_bestfit, pars, $
    DEGREE=degree, MDEGREE=mdegree, $
	STAR=star, WEIGHTS=weights, $
    LAMBDA=lambda,$
    POLYWEIGHTS = polyweights, $
    RANGE = range  ; for Legendre polynomial 
; Based on ppxf_fitfunc_optimal_template (match ppxf version V4.7.10 and LZIFU v1 implementation) 
; Without doing bvls minimization. Directly output spectra using input parameters. 
; This is for reconstructing the different components of the best-fit continuum

vsyst  = 0.
factor = 1.
s = size(star) 
npix = s[1]      ; Number of channels
ntemp = s[2]     ; Number of template spectra
npars = n_elements(pars) - mdegree  ; Parameters of the LOSVD only
if mdegree le 0 then npars = npars - 1 ; Fitting reddening

; pars = [vel,sigma,h3,h4,...,m1,m2,...]    ; Velocities are in pixels
;
dx = ceil(abs(vsyst)+abs(pars[0])+5d*pars[1]) ; Sample the Gaussian and GH at least to vsyst+vel+5*sigma
n = 2*dx*factor + 1
x = cap_range(dx,-dx,n)   ; Evaluate the Gaussian using steps of 1/factor pixel
losvd = dblarr(n,/NOZERO)

s = 1
vel = vsyst + s*pars[0]
w = (x - vel)/pars[1]
w2 = w^2
gauss = exp(-0.5d*w2)
losvd = gauss/total(gauss)

; Hermite polynomials normalized as in Appendix A of van der Marel & Franx (1993).
; These coefficients are given e.g. in Appendix C of Cappellari et al. (2002)
;

if npars gt 2 then begin
    poly = 1d + s*pars[2]/Sqrt(3d)*(w*(2d*w2-3d)) $     ; H3
              + pars[3]/Sqrt(24d)*(w2*(4d*w2-12d)+3d)   ; H4
    if npars eq 6 then $
        poly = poly + s*pars[4]/Sqrt(60d)*(w*(w2*(4d*w2-20d)+15d)) $    ; H5
                    + pars[5]/Sqrt(720d)*(w2*(w2*(8d*w2-60d)+90d)-15d)  ; H6
    losvd = losvd*poly
endif


;;; Make X-vector on the blue or red grid. 
xx = cap_range(-1,1,(alog(range[1])-alog(range[0]))/(alog(lambda[1])-alog(lambda[0])))
x = interpol(xx,alog(range[0])+findgen(n_elements(xx))*(alog(lambda[1])-alog(lambda[0])),alog(lambda))
ind = where(x lt -1,cnt) & if cnt gt 0 then x[ind] = -1
ind = where(x gt 1,cnt)  & if cnt gt 0 then x[ind] = 1

;;;;;;;; Build multiplicative legendre polynomials ;;;;;;;;;;;;;;;;
mpoly = dblarr(npix) + 1  ; The loop below can be null if mdegree < 1
for j=1,mdegree do $
    mpoly = mpoly + legendre(x,j) * pars[npars+j-1]

; When multiplicative polynomials aren't fit then return reddening
if mdegree le 0 then mpoly = ppxf_reddening_curve(lambda, pars[npars])

; Fill the columns of the design matrix of the least-squares problem
s = size(star) 
nrows = (degree + 1 ) + ntemp
ncols = npix
c = dblarr(ncols,nrows)  ; This array is used for estimating predictions


;;;;;;;; Additive legendre polynoimal ;;;;;;;;;;;;;;;;

for j=0,degree do c[0,j] = legendre(x,j) ; Fill in additive polynomials
    
;;;;;;;; Stellar templates ;;;;;;;;;;;;;;;;

for j=0,ntemp-1 do c[0,(degree+1)+j] = mpoly * ppxf_convol_fft(star[*,j],losvd) ;Fill in stellar templates

;;;;;;;; Reconstruct output ;;;;;;;;;;;;;;;;;;;;;;;;;;
if degree ge 0 then begin
	bestfit = c[0:npix-1,*] # reform([polyweights,weights],n_elements(polyweights)+n_elements(weights))
	addpoly = c[0:npix-1,0:degree] # polyweights
endif else begin
	bestfit = c[0:npix-1,*] # reform(weights,n_elements(weights))
	addpoly = bestfit * 0
endelse

return, {bestfit:bestfit,addpoly:addpoly,mpoly:mpoly}

END
