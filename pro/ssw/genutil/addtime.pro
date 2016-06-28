function addtime, A, delta_min=delta_min, difference=B, secs=secs
;+
;  Name:
;    ADDTIME
;  Purpose:
;    If optional keyword delta_min is supplied, then add a offset in 
;		decimal minutes to an external time (H,M,S,MS,D,M,Y).
;    If optional keyword difference is supplied, return the difference 
;		as Value = [A] - [B], where Value will be minutes (floating).
;
;  Inputs:
;    A	= Base time, any format.
;
;  Calling Sequence:
;    Result = addtime(A,delta_min=delta_min)	; Result is [h,m,s,ms,d,m,y]
;    Result = addtime(A,difference=B)		; Result is minutes (float)
;    Result = addtime(A,difference=B,/sec)	; Result is seconds (float)
;
;  Outputs:
;    Function returns New time time, if delta_min keyword is provided.
;    Function returns difference of A-B, if B keyword is provied.
;
;  OPTIONAL INPUT KEYWORDS:
;    delta_min	Decimal minutes (positive or negative) to add to A.
;		If /secs is set, this should be in secs.
;    B		2nd time to subtract from A in any format.
;    secs	If set, return the result in seconds with diff=keyword
;               If set, the input delta should be specified in secs
;
;  Procedure:
;    Calls ex2int and int2ex to do the calculations. 
;
;  MODIFICATION HISTORY:
;    15-oct-91, Written, JRL
;    26-oct-91, Update, JRL - To handle hrs > 24 case
;    22-jun-92, Update, JRL - eliminate the 24:00 hour case
;    11-sep-92, Update, JRL - Call anytim2ex to convert input to external.
;    27-jul-94, JRL - Return the result in secs (with massive help from JMM!)
;     6-Mar-95, JRL - Improved logic so delta=<large numbers> doesn't overflow
;-

str_info = ['Result = addtime(A,delta_min=delta) ; Result is [h,m,s,ms,d,m,y]',$
            'Result = addtime(A,difference=B)    ; Result is minutes (float)', $
	    'Result = addtime(A,diff=B,/sec)     ; Result is seconds (float)']

if n_params() eq 0 then return,str_info

;  Figure out which mode to operate in:

if n_elements(B)         eq 0 then qdiff = 0 else qdiff = 1
if n_elements(delta_min) eq 0 then qdelt = 0 else qdelt = 1

if qdiff and qdelt then begin
  print,'  **** addtime error  **** '
  print,' Cannot specify both keywords'
  print,' The calling sequence is:'
  print,str_info,format='(x,a)'
  return,str_info
endif

if not qdiff and not qdelt then begin 		; No arguments supplied
  print,'  **** addtime warning **** '
  print,' No keyword parameters supplied'
  return,A					; Just return the input time
endif

;  Convert A to internal format:

AA = anytim2ex(A)				; Convert to external if nec.
ex2int,AA,msodA,ds79A				; Convert to internal

;  difference keyword specified:

if qdiff then begin
  BB = anytim2ex(B)				; Convert to external if nec.
  ex2int,BB,msodB,ds79B				; Convert to internal

  delta_msod = msodA-msodB
  delta_ds79 = ds79A-ds79B
  delta_sec  = delta_ds79*24*60.*60. + delta_msod / 1000. 

  if keyword_set(secs) then return,delta_sec else return,delta_sec / 60.

endif else begin

  
  if keyword_set(secs) then delta_sec = delta_min else delta_sec = delta_min * 60.d0 
  delta_day = long(delta_sec / (24L*60*60))			; delta in days
  delta_msec = round((delta_sec-(delta_day*24L*60*60))* 1000.d0); delta in millisec
  if n_elements(delta_msec) ne n_elements(msodA) then begin
     if n_elements(delta_msec) ne 1 then $
       message,'*** Warning:  Length of DELTA does not match length of input time',/cont
     delta_msec = replicate(delta_msec(0),n_elements(msodA)) 
  endif
  ds79 = ds79A + delta_day
  msod = msodA + delta_msec
  msec_day = 24L*60*60*1000				; # msec in a day

; Do we need to move back a day?
  repeat begin
    ss = where(msod lt 0,ncount)
    if ncount gt 0 then begin
      ds79(ss) = ds79(ss) - 1
      msod(ss) = msod(ss) + msec_day			; # msec in a day
    endif 
  endrep until ncount eq 0

; Do we need to move forward a day?
  repeat begin
    ss = where(msod ge msec_day,ncount)
    if ncount gt 0 then begin
      msod(ss) = msod(ss) - msec_day			; # msec in a day
      ds79(ss) = ds79(ss) + 1
    endif	
  endrep until ncount eq 0
 
  int2ex,[msod],[ds79],C
  return,C						; h,m,s,ms,d,m,y 
endelse

end
