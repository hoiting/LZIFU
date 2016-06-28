FUNCTION lzifu_load_2d_mask,set
; load an external 2d mask

	if not file_exist(set.mask_2d_path + '/' + set.mask_2d_name) then begin
		message,"Cannot find file:"+set.mask_2d_path + '/' + set.mask_2d_name
	endif
	
	mask = mrdfits(set.mask_2d_path + '/' + set.mask_2d_name,0)
	s = size(mask,/dimension)
	if s[0] NE set.xsize or s[1] NE set.ysize then begin
		message,"Mask size does not match data cube size"
	endif
	
	return,mask

END