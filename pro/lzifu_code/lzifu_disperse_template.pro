FUNCTION lzifu_disperse_template, template, lambda, sigma_wl
	; This function assumes that the dispersion is perfectly linear in wavelength 
	; space. 
  dispersion = lambda[1]-lambda[0]
  sigma_pix = sigma_wl / dispersion
  kernelsize = 7.*sigma_pix

  npoints = size(template)
  new_temp = template

   ; build kernel
  kernel = dindgen(kernelsize) - (kernelsize-1)/2
  kernel = exp( -kernel^2d/(2d*sigma_pix^2d) )
  kernel /= total(kernel)

  for l=0,npoints[2] -1 do begin
      ; convolve each template with the kernel 
	 new_temp[*,l] = convol (template[*,l], kernel,/EDGE_TRUNCATE ,/NAN)
  endfor



  return, new_temp

END
