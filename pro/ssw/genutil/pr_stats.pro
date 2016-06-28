pro pr_stats1, arr, i, info, n
;
;
idev = stdev(arr, iavg)
imin = min(arr)
imax = max(arr)
;
if (n_elements(i) ne 0) then begin
    print, i, format='(i6, $)'
    if (i eq 0) then begin
        info0 = {time:0L, day:0, avg:0., dev:0., min:0., max:0.}
        info = replicate(info0, n)
    end
end
;
print, imin, imax, iavg, idev
;
if (keyword_set(info)) then begin
    info(i).avg = iavg
    info(i).dev = idev
    info(i).min = imin
    info(i).max = imax
end
;
end
;-----------------------------------------------
pro pr_stats, arr, dim, info
;+
;NAME:
;	pr_stats
;PURPOSE:
;	To print the min/max/avg/dev for an array
;	Optionally loop through one of the dimensions
;	Returns a structure with what it had found
;SAMPLE CALLING SEQUENCE:
;	pr_stats, var
;	pr_stats, var_3d_arr, 1
;	pr_stats, var, dim, info
;	pr_stats, filename_arr, junk, info
;INPUT:
;	var	- The variable to get the stats on
;				(OR)
;		  the list of FITS file names to process
;OPTIONAL INPUT
;	dim	- The dimension to cycle through
;OUTPUT:
;	info	- A structure with tags
;			.avg - holds the average
;			.dev - holds the standard deviation
;			.min - holds the minimum
;			.max - holds the maximum
;HISTORY:
;	Written 1996 by M.Morrison
;	 6-Nov-96 (MDM) - Added documentation header
;	 2-Jul-97 (MDM) - Added FITS filename array option
;-
;
if (data_type(arr) eq 7) then begin	;file names
    n = n_elements(arr)
    for i=0,n-1 do begin
	img = [0,0]
	if (file_exist(arr(i))) then img = rfits(arr(i), h=h)
	pr_stats1, img, i, info, n
    end
    return
end
;
if (n_elements(dim) eq 0) then begin
    pr_stats1, arr
end else begin
    case dim of 
	1: begin & n=n_elements(arr(*,0,0,0,0)) & for i=0,n-1 do pr_stats1, arr(i,*,*,*,*), i, info, n & end
	2: begin & n=n_elements(arr(0,*,0,0,0)) & for i=0,n-1 do pr_stats1, arr(*,i,*,*,*), i, info, n & end
	3: begin & n=n_elements(arr(0,0,*,0,0)) & for i=0,n-1 do pr_stats1, arr(*,*,i,*,*), i, info, n & end
	4: begin & n=n_elements(arr(0,0,0,*,0)) & for i=0,n-1 do pr_stats1, arr(*,*,*,i,*), i, info, n & end
	5: begin & n=n_elements(arr(0,0,0,0,*)) & for i=0,n-1 do pr_stats1, arr(*,*,*,*,i), i, info, n & end
	else: print, 'Dim GT 5 not accepted
    endcase
end

end
