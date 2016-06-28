pro mapx, ids, map=map, show=show, sensitive=sensitive
;
;+
;   Name:mapx
;
;   Purpose: hide/show map/unmap sensitize/desensitize widgets
;
;   Input Parameters:
;      ids - widget id(s) to map/show - longword vector or scaler
;      show     - vector or scaler show parameter
;      map=map	- vector or scaler map parameter 
;      sensitive=sensitive - vector or scaler sensitive parameter 
;      All parameters default to OFF (unmap, hide, desensitize)
;
;   History: slf, 7/91
;   	     slf, 2-8-92 - added sensitive parameter
;			   allow vectors for parameters
;	     slf, 31-oct-93 - added bad_id=destroyed
;-
n_ids=n_elements(ids)
;
if n_elements(show) le 1 then $
    show = replicate(keyword_set(show),n_ids)
;
if n_elements(map) le 1 then $
    map  = replicate(keyword_set(map),n_ids)
;
if n_elements(sensitive) le 1 then $
    sensitive=replicate(keyword_set(sensitive),n_ids)
;
valid = where(ids)
for i=0, n_elements(valid)-1 do $
   widget_control, ids(valid(i)), bad_id=destroyed, $
	map=map(i), show=show(i), sensitive=sensitive(i)
return
end
