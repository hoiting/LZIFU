FUNCTION lzifu_mask_emission, lambda, linelambda, halfwidth

  good = indgen(n_elements(lambda))
  nn = n_elements(linelambda)

  for i = 0, nn - 1 do begin
     gg = where(lambda[good] lt linelambda[i] - halfwidth[i] or $
                lambda[good] gt linelambda[i] + halfwidth[i])
     good = good[gg]
  endfor

  return, good

END
