FUNCTION lzifu_load_cube,set

	path = set.data_path

	print,'Loading data from '+ path
	name = path + set.obj_name 

	if set.only_1side eq 0 then begin  ; two-sided data
		if file_exist(name+'_R.fits') then begin
			r_cube       = mrdfits(name+'_R.fits',0,r_h,/silent)
			r_cube_err   = sqrt(mrdfits(name+'_R.fits',1,/silent))
			r_cube_bpix  = mrdfits(name+'_R.fits',2,/silent)
		endif
		if file_exist(name+'_R.fits.gz') then begin
			r_cube       = mrdfits(name+'_R.fits.gz',0,r_h,/silent)
			r_cube_err   = sqrt(mrdfits(name+'_R.fits.gz',1,/silent))
			r_cube_bpix  = mrdfits(name+'_R.fits.gz',2,/silent)
		endif
		if not exist(r_cube) then begin
			message,"Can't find " + name+'_R.fits(.gz)'
		endif

		if file_exist(name+'_B.fits') then begin
			b_cube       = mrdfits(name+'_B.fits',0,b_h,/silent)
			b_cube_err   = sqrt(mrdfits(name+'_B.fits',1,/silent))
			b_cube_bpix  = mrdfits(name+'_B.fits',2,/silent)
		endif
		if file_exist(name+'_B.fits.gz') then begin
			b_cube       = mrdfits(name+'_B.fits.gz',0,b_h,/silent)
			b_cube_err   = sqrt(mrdfits(name+'_B.fits.gz',1,/silent))
			b_cube_bpix  = mrdfits(name+'_B.fits.gz',2,/silent)
		endif
		if not exist(b_cube) then begin
			message,"Can't find " + name+'_B.fits(.gz)'
		endif

		s = size(r_cube,/dimension)

		r_lambda = (findgen(sxpar(r_h,'naxis3'))+1-sxpar(r_h,'crpix3'))*sxpar(r_h,'cdelt3')+sxpar(r_h,'crval3')
		b_lambda = (findgen(sxpar(b_h,'naxis3'))+1-sxpar(b_h,'crpix3'))*sxpar(b_h,'cdelt3')+sxpar(b_h,'crval3')


		set.r_channel_width = sxpar(r_h,'cdelt3')
		set.b_channel_width = sxpar(b_h,'cdelt3')

		; Add data size to set
		r_s=size(r_cube)  &	 b_s=size(b_cube)
		set.xsize = r_s[1] & set.ysize = r_s[2] & set.b_zsize = b_s[3] & set.r_zsize = r_s[3]

		; Add Z_LZIFU to header. 
		sxaddpar,b_h,'Z_LZIFU',set.z[0],'LZIFU: Input (reference) redshift of the object.'
		sxaddpar,r_h,'Z_LZIFU',set.z[0],'LZIFU: Input (reference) redshift of the object.'

		; Add header to set	
		set = add_tag(set,b_h,'b_header')
		set = add_tag(set,r_h,'r_header')
		
		; Check for NaNs in data and error
		ind = where(~finite(r_cube) or ~finite(r_cube_err),cnt)
		if cnt ge 1 then r_cube_bpix[ind] = 1
		ind = where(~finite(b_cube) or ~finite(b_cube_err),cnt)
		if cnt ge 1 then b_cube_bpix[ind] = 1
		
	endif else begin   ; 1-sided data
		if file_exist(name+'.fits') then begin
			r_cube       = mrdfits(name+'.fits',0,r_h,/silent)
			r_cube_err   = sqrt(mrdfits(name+'.fits',1,/silent))
			r_cube_bpix  = mrdfits(name+'.fits',2,/silent)
		endif
		if file_exist(name+'.fits.gz') then begin
			r_cube       = mrdfits(name+'.fits.gz',0,r_h,/silent)
			r_cube_err   = sqrt(mrdfits(name+'.fits.gz',1,/silent))
			r_cube_bpix  = mrdfits(name+'.fits.gz',2,/silent)
		endif
		if not exist(r_cube) then begin
			print,"Can't find " + name+'.fits(.gz)'
			stop
		endif
		r_lambda = (findgen(sxpar(r_h,'naxis3'))+1-sxpar(r_h,'crpix3'))*sxpar(r_h,'cdelt3')+sxpar(r_h,'crval3')		
		set.r_channel_width = sxpar(r_h,'cdelt3')


		; Add data size to set
		r_s=size(r_cube)  
		set.xsize = r_s[1] & set.ysize = r_s[2] & set.r_zsize = r_s[3]

		; Add Z_LZIFU to header. For Slide3d to use later. 
		sxaddpar,r_h,'Z_LZIFU',set.z[0],'LZIFU: Input (reference) redshift of the object.'

		; Add header to set	
		set = add_tag(set,'NaN','b_header')
		set = add_tag(set,r_h,'r_header')

		; Check for NaNs in data and error
		ind = where(~finite(r_cube) or ~finite(r_cube_err),cnt)
		if cnt ge 1 then r_cube_bpix[ind] = 1

		; fake blue cube
		b_cube      = fltarr(set.xsize,set.ysize,2) + 1
		b_cube_err   = b_cube
		b_cube_bpix  = fltarr(size(b_cube,/dim))
		b_lambda     = [10,11] ; fake lambda
		set.b_channel_width = 1.
		set.b_zsize         = 2

	endelse 
	print,'Finishing loading data.'

	; return data
	datacube = {datacube, $
				r_cube        :   r_cube,      $
	            r_cube_err    :   r_cube_err,  $
	            r_cube_bpix   :   r_cube_bpix, $
	            r_lambda      :   r_lambda,    $
	            b_cube        :   b_cube,      $
	            b_cube_err    :   b_cube_err,  $
	            b_cube_bpix   :   b_cube_bpix, $
	            b_lambda      :   b_lambda    $
	            }
	return,datacube

END