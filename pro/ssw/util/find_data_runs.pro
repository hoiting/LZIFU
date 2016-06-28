;+
; Project     : SOHO - CDS     
;                   
; Name        : FIND_DATA_RUNS()
;               
; Purpose     : Detect runs of data in an array and return their boundaries.
;               
; Explanation : This function finds valid data windows in a data array. 
;               Valid windows are those containing data not having a value 
;               equal to the 'invalid' flag and having at least 'min_data_win' 
;               valid data points in them. Groups with less than this number 
;               of data points are ignored. A break in the data window is 
;               also considered to have occurred if the time interval between 
;               successive valid data points is greater than 'max_time_int'
;               units. 
;               
; Use         : IDL> limits = find_data_runs(x, y, invalid, min_data_win, $
;                                            max_time_int [,maxrun=maxrun])
;    
; Inputs      : x        -  input data array 'time' values
;
;               y        -  input data array data values
;
;               invalid  -  value of datum to be ignored
;
;               min_wind_size  -  chosen data runs must contain at least this 
;                                 many data points otherwise they are ignored.
;
;               max_time_step  -  maximum 'time' step which is considered 
;                                 legitimate within a window. If two 
;                                 consecutive data points in the x array are 
;                                 separated in value by more than this then a 
;                                 new data window is started.
;
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns start and stop indices (in input arrays) of
;               runs of valid data as a 2-d array. eg:
;                  dw = find_data_runs(x,y.......)
;               then dw(0,0) will be the start index of the first run
;                    dx(0,1) the stop index of the first run
;                    dx(1,0) the start index of the second run etc etc
;
;               Example:
;                          y = [0,0,1,1,1,0,0,0,1,1,0,1,1]
;                          dw = find_data_runs(indgen(13),y,0,0,1)
;                          print, dw  will give
;                           2  8  11
;                           4  9  12
;
;               An array [-1,-1] is returned if no valid data runs are found.
;               
; Opt. Outputs: None
;               
; Keywords    : maxrun - max number of data points in a run.  A new run
;                        is started when this limit is reached.
;
; Calls       : None
;               
; Restrictions: x and y array inputsmust be of the same size.
;               
; Side effects: None
;               
; Category    : Util, misc
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 16-Nov-93
;               
; Modified    : Add maxrun keyword.  CDP, 1-Nov-94
;
; Version     : Version 2, 1-Nov-94
;-            

function find_data_runs, x, y, invalid, min_data_wind,$
                               max_time_int,maxrun=maxrun

;
;  check parameters
;
if n_params() ne 5 then begin
   print,'Use:  dw = find_data_runs(x,y,invalid,min_wind_size, max_time_step)'
   return, [-1,-1]
endif

;
;  English flags
;

YES = 1
NO = 0
all_good = NO
all_bad  = NO

;
;  make temporary arrays so that always have first and last invalid point
;  this makes the determination of window limits much easier
;

tx = [x(0),x,x(n_elements(x)-1)]
ty = [invalid,y,invalid]
savety = ty

;
;  loop around until situation is stable ie no further points left out
;

change = YES
while (change eq YES) do begin
   change = NO

;
;  store mask for in/valid data points
;
   temp = intarr(n_elements(ty))

;
;  good points
;

   dd = where(ty ne invalid)
   if n_elements(dd) eq n_elements(ty) then all_good = YES
   if n_elements(dd) eq 1 then begin
      if dd(0) ge 0 then temp(dd) = YES
   endif  else begin
      temp(dd) = YES
   endelse

;
;  bad points
;

   dd = where(ty eq invalid)
   if n_elements(dd) eq n_elements(ty) then all_bad = YES
   if n_elements(dd) eq 1 then begin
      if dd(0) ge 0 then temp(dd) = NO
   endif else begin
      temp(dd) = NO
   endelse

;
;  check for adjacent good points with large x-value gap
;  and set temporary invalid point there to be picked up as a gap
;  It is later put back
;

   diff = tx - shift(tx,-1)
   nd = where(abs(diff(1:n_elements(diff)-2)) gt max_time_int)
   if n_elements(nd) eq 1 then begin
      if nd(0) ge 0 then temp(nd+2) = NO
   endif else begin
      temp(nd+2) = NO
   endelse
   
;
;  find switches of data from good to bad and vv
;
   start_data = intarr(500)
   end_data   = intarr(500)
;
;  differentiate valid mask array
; 
   dd   = temp - shift(temp,-1)
   start_data = where(dd eq -1) + 1
   end_data   = where(dd eq 1) + 1
;
;   cut out spurious end point
;
   start_data = start_data(where(start_data lt n_elements(tx)))
   end_data = end_data(where(end_data lt n_elements(tx)))

;
;  check for no gaps
;
   if (n_elements(start_data) eq 1) then begin
      if start_data(0) eq 0 then begin
         if all_good eq YES then begin
            data_windows = intarr(1,2)
            data_windows(0,0) = 0
            data_windows(0,1) = n_elements(ty)-1
            return, data_windows
         endif
      endif
   endif
   if (n_elements(end_data) eq 1) then begin
      if end_data(0) eq 0 then begin
         if all_bad eq YES then begin
            data_windows = intarr(1,2)
            data_windows(0,0) = -1
            data_windows(0,1) = -1
            return, data_windows
         endif
      endif
   endif
   
;
;  check for data windows being too small in which case 
;  just kill them by giving the data within them the invalid value.
;  Before doing that, check that the datum before the start of the window
;  was invalid in the original data, if not it has been changed to indicate a
;  'time' gap so window size was probably ok
;
   for i=0,n_elements(start_data)-1 do begin 
      if(end_data(i) - start_data(i) + 1) le min_data_wind and $
                     (savety(start_data(i)-1) eq invalid) then begin
         ty(start_data(i):end_data(i)) = invalid
         change = YES
      endif
   endfor
endwhile

;
;  put back the valid points that were temporarily set bad to aid gap finding
;

for i=1,n_elements(start_data)-1 do begin
   if start_data(i) ge 1 then begin
      if savety(start_data(i)-1) ne invalid then start_data(i) = start_data(i) - 1
   endif
endfor

;
;  set up data windows to be returned
;

data_windows = intarr(n_elements(start_data),2)
for i=0,n_elements(start_data)-1 do begin
   data_windows(i,0) = start_data(i)-1
   data_windows(i,1) = end_data(i)-2
endfor

;
;  was a limit on the size of runs set?
;
if keyword_set(maxrun) then begin
   out = intarr(n_elements(x),2)
   nout = 0
   
   for i=0,(n_elements(data_windows)/2)-1 do begin
      xlen = data_windows(i,1) - data_windows(i,0) + 1
      if xlen gt maxrun then begin
         nb = xlen/maxrun + 1
         if (xlen mod maxrun) eq 0 then nb = nb - 1
         for j=0,nb-1 do begin
            if j eq 0 then begin
               out(nout,0) = data_windows(i,0)
            endif else begin
               out(nout,0) = out(nout-1,1) + 1
            endelse
            out(nout,1) = out(nout,0) + (xlen < maxrun) - 1
            xlen = xlen - maxrun
            nout = nout + 1
         endfor
      endif else begin
         out(nout,0) = data_windows(i,0)
         out(nout,1) = data_windows(i,1)
         nout = nout + 1
      endelse
   endfor

   n = where(out(*,1) gt 0)
   out = out(n,*)
   return,out

endif else begin

   return, data_windows
endelse
end
