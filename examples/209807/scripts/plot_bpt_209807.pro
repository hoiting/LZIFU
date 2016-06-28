PRO plot_bpt_209807

	sig_cut = 3.
	; Load data
	ha     = mrdfits('../products/209807_merge_comp.fits','HALPHA')
	ha_err = mrdfits('../products/209807_merge_comp.fits','HALPHA_ERR')
	hb     = mrdfits('../products/209807_merge_comp.fits','HBETA')
	hb_err = mrdfits('../products/209807_merge_comp.fits','HBETA_ERR')
	n2     = mrdfits('../products/209807_merge_comp.fits','NII6583')
	n2_err = mrdfits('../products/209807_merge_comp.fits','NII6583_ERR')
	s21    = mrdfits('../products/209807_merge_comp.fits','SII6716')
	s21_err= mrdfits('../products/209807_merge_comp.fits','SII6716_ERR')
	s22    = mrdfits('../products/209807_merge_comp.fits','SII6731')
	s22_err= mrdfits('../products/209807_merge_comp.fits','SII6731_ERR')
	o1     = mrdfits('../products/209807_merge_comp.fits','OI6300')
	o1_err = mrdfits('../products/209807_merge_comp.fits','OI6300_ERR')
	o3     = mrdfits('../products/209807_merge_comp.fits','OIII5007')
	o3_err = mrdfits('../products/209807_merge_comp.fits','OIII5007_ERR')
	s2     = s21 + s22
	s2_err = sqrt(s21_err^2 + s22_err^2)

	; plotting
	window,xsize=1000,ysize=300
	!P.MULTI=[0,3,1]
	!P.CHARSIZE=3
	; N2-Halpha BPT
	plot,indgen(10),/nodata,xrange=[-1,1],yrange=[-1,0.8],/xsty,/ysty,ytitle='log([OIII]/Hbeta)',xtitle='log([NII]/Halpha)'
	ind = where(n2[*,*,1] gt sig_cut * n2_err[*,*,1] and ha[*,*,1] gt sig_cut * ha_err[*,*,1] and o3[*,*,1] gt sig_cut * o3_err[*,*,1] and hb[*,*,1] gt sig_cut * hb_err[*,*,1] )
	oplot,(alog10(n2[*,*,1]/ha[*,*,1]))[ind],(alog10(o3[*,*,1]/hb[*,*,1]))[ind],psym=4,color=cgcolor('blue')
	ind = where(n2[*,*,2] gt sig_cut * n2_err[*,*,2] and ha[*,*,2] gt sig_cut * ha_err[*,*,2] and o3[*,*,2] gt sig_cut * o3_err[*,*,2] and hb[*,*,2] gt sig_cut * hb_err[*,*,2] )
	oplot,(alog10(n2[*,*,2]/ha[*,*,2]))[ind],(alog10(o3[*,*,2]/hb[*,*,2]))[ind],psym=4,color=cgcolor('orange')
	ind = where(n2[*,*,3] gt sig_cut * n2_err[*,*,3] and ha[*,*,3] gt sig_cut * ha_err[*,*,3] and o3[*,*,3] gt sig_cut * o3_err[*,*,3] and hb[*,*,3] gt sig_cut * hb_err[*,*,3] )
	oplot,(alog10(n2[*,*,3]/ha[*,*,3]))[ind],(alog10(o3[*,*,3]/hb[*,*,3]))[ind],psym=4,color=cgcolor('red')
	; BPT curves
	n2bptx1 = findgen(100)/100 - 1.1
	n2bpty1 = 0.61/(n2bptx1-0.05)+1.3
	n2bptx2 = findgen(310)/100 - 2.8
	n2bpty2 = 0.61/(n2bptx2-0.47)+1.19
	oplot,n2bptx1,n2bpty1,linestyle=2 ; Kauffmann et al. (2003) curve
	oplot,n2bptx2,n2bpty2,linestyle=0 ; Kewley et al. (2001) curve

	; S2-Halpha BPT
	plot,indgen(10),/nodata,xrange=[-1,1],yrange=[-1,0.8],/xsty,/ysty,ytitle='log([OIII]/Hbeta)',xtitle='log([SII]/Halpha)'
	ind = where(s2[*,*,1] gt sig_cut * s2_err[*,*,1] and ha[*,*,1] gt sig_cut * ha_err[*,*,1] and o3[*,*,1] gt sig_cut * o3_err[*,*,1] and hb[*,*,1] gt sig_cut * hb_err[*,*,1] )
	oplot,(alog10(s2[*,*,1]/ha[*,*,1]))[ind],(alog10(o3[*,*,1]/hb[*,*,1]))[ind],psym=4,color=cgcolor('blue')
	ind = where(s2[*,*,2] gt sig_cut * s2_err[*,*,2] and ha[*,*,2] gt sig_cut * ha_err[*,*,2] and o3[*,*,2] gt sig_cut * o3_err[*,*,2] and hb[*,*,2] gt sig_cut * hb_err[*,*,2] )
	oplot,(alog10(s2[*,*,2]/ha[*,*,2]))[ind],(alog10(o3[*,*,2]/hb[*,*,2]))[ind],psym=4,color=cgcolor('orange')
	ind = where(s2[*,*,3] gt sig_cut * s2_err[*,*,3] and ha[*,*,3] gt sig_cut * ha_err[*,*,3] and o3[*,*,3] gt sig_cut * o3_err[*,*,3] and hb[*,*,3] gt sig_cut * hb_err[*,*,3] )
	oplot,(alog10(s2[*,*,3]/ha[*,*,3]))[ind],(alog10(o3[*,*,3]/hb[*,*,3]))[ind],psym=4,color=cgcolor('red')
	; BPT curves
	s2bptx1 = -1.*findgen(200)/100 + 0.32
	s2bpty1 = 0.72/(s2bptx1-0.32)+1.3
	s2bptx2 = findgen(40)/100 - 0.3
	s2bpty2 = 1.89*s2bptx2 + 0.76
	oplot,s2bptx1,s2bpty1,linestyle=0 ; Kewley et al. (2001) curve
	oplot,s2bptx2,s2bpty2,linestyle=1 ; Kewley et al. (2006) line

	
	; O1-Halpha BPT
	plot,indgen(10),/nodata,xrange=[-2.5,0],yrange=[-1,0.8],/xsty,/ysty,ytitle='log([OIII]/Hbeta)',xtitle='log([OI]/Halpha)'
	ind = where(o1[*,*,1] gt sig_cut * o1_err[*,*,1] and ha[*,*,1] gt sig_cut * ha_err[*,*,1] and o3[*,*,1] gt sig_cut * o3_err[*,*,1] and hb[*,*,1] gt sig_cut * hb_err[*,*,1] )
	oplot,(alog10(o1[*,*,1]/ha[*,*,1]))[ind],(alog10(o3[*,*,1]/hb[*,*,1]))[ind],psym=4,color=cgcolor('blue')
	ind = where(o1[*,*,2] gt sig_cut * o1_err[*,*,2] and ha[*,*,2] gt sig_cut * ha_err[*,*,2] and o3[*,*,2] gt sig_cut * o3_err[*,*,2] and hb[*,*,2] gt sig_cut * hb_err[*,*,2] )
	oplot,(alog10(o1[*,*,2]/ha[*,*,2]))[ind],(alog10(o3[*,*,2]/hb[*,*,2]))[ind],psym=4,color=cgcolor('orange')
	ind = where(o1[*,*,3] gt sig_cut * o1_err[*,*,3] and ha[*,*,3] gt sig_cut * ha_err[*,*,3] and o3[*,*,3] gt sig_cut * o3_err[*,*,3] and hb[*,*,3] gt sig_cut * hb_err[*,*,3] )
	oplot,(alog10(o1[*,*,3]/ha[*,*,3]))[ind],(alog10(o3[*,*,3]/hb[*,*,3]))[ind],psym=4,color=cgcolor('red')
	; BPT curves
	o1bptx1 = -1.*findgen(200)/100 - 0.59
	o1bpty1 = 0.73/(o1bptx1+0.59) + 1.33
	o1bptx2 = findgen(60)/100 - 1.1
	o1bpty2 = 1.18 * o1bptx2 + 1.3
	oplot,o1bptx1,o1bpty1,linestyle=0 ; Kewley et al. (2001) curve
	oplot,o1bptx2,o1bpty2,linestyle=1 ; Kewley et al. (2006) line

	; add legend
	al_legend,['c1','c2','c3'],color=[cgcolor('blue'),cgcolor('orange'),cgcolor('red')],$
	psym=[4,4,4],charsize=1.5,/top,/left

END