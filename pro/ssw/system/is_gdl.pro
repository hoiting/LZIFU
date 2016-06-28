;+
;Name: IS_GDL
;
;Purpose: This function is the most simple-minded test to see
;	if you are using GDL and not using IDL
;
;Method: searches the !prompt string for 'GDL' or tests
;	for the ISGDL environment variable
;History: 9-April-2007 Richard.schwartz@gsfc.nasa.gov,
;-

function is_gdl, x, _extra=_extra

RETURN,fix(getenv('ISGDL')) or  strpos(strupcase(!prompt),'GDL') ne -1

end
