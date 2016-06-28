
z=['m1.31','m0.71','m0.40','p0.00','p0.22']

age=[0.0631000,0.0708000,0.0794000,0.0891000,0.100000,0.112200,0.125900,0.141300,0.158500,0.177800,0.199500,0.223900,0.251200,0.281800,0.316200,0.354800,0.398100,0.446700,0.501200,0.562300,0.631000,0.707900,0.794300,0.891300,1.00000,1.12200,1.25890,1.41250,1.58490,1.77830,1.99530,2.23870,2.51190,2.81840,3.16230,3.54810,3.98110,4.46680,5.01190,5.62340,6.30960,7.07950,7.94330,8.91250,10.0000,11.2202,12.5893,14.1254,15.8489,17.7828]

for i=0,n_elements(z)-1 do begin
	file=findfile('fits/Mun1.30Z'+z[i]+'*.fits')
	; 50 age bins
	for j=0,n_elements(file)-1 do begin
		starflux = mrdfits(file[j],0,h)
		if j EQ 0 then begin ; first time
			starlambda = (findgen(sxpar(h,'NAXIS1'))+1-sxpar(h,'CRPIX1'))*sxpar(h,'CDELT1')+sxpar(h,'CRVAL1')   
			template = { lambda:starlambda, flux:starflux}
		endif else $
			template = { lambda:template.lambda, flux:[[template.flux],[starflux]], age_myr: age*1e3}
	endfor
	; save template
	save,filename='miles_'+z[i]+'.sav',template
		
	cond_ind = indgen(13)*4
	cond_age = age[cond_ind]
	
	template = {lambda:template.lambda, flux: template.flux[*,cond_ind], age_myr: cond_age*1e3}	
	save,filename='cond_miles_'+z[i]+'.sav',template
	
endfor

END



