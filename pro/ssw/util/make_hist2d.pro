;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;+
; Name:
;
;      MAKE_HIST2D
;
; Purpose:
;
;      Form a 2-D histogram from two arrays or images.
;
; Category:
;
;      Data processing
;
; Calling sequence:
;
;      hist_img = MAKE_HIST2D(image1,image2 [ , MISSING=missing ,
;                             /XLOG           , /YLOG ,
;                             XHRANGE=xrange  , YHRANGE=yrange ,
;                             XBIN=xbin       , YBIN=ybin ,
;                             INFO=hist_info  , IMAGES=hist_input ] )
;
; Inputs:
;
;      image1: 1st image (or set of images) [X]
;      image2: 2nd image (       "        ) [Y]
;
; Keyword parameters:
;
;      MISSING = value flagging missing/bad pixels (IN)
;      X/YLOG = use log of X/Y? (IN)
;      X/YHRANGE = range of X/Y values to be used in forming the histogram (IN)
;      X/YBIN = X/Y binning (IN)
;      INFO   = info. (dimension, origin, binsize) about the histogram array; 
;               array (2 elements) of structures (OUT), tags:
;                 dim: i-th dimension of the histogram image;
;                 zero: origin of the i-th axis;
;                 bin: bin factor for the i-th axis;
;                 log: (boolean) histogram in logarithm space?
;      IMAGES = actual images used to form the histogram; structure (OUT), tags:
;                 flt: float input array (log scaled, if X/YLOG is set);
;                 int: integer-scaled input array;
;               Given in output only if explicitly requested by setting 
;               hist_input to some value.
;
; Output:
;
;      hist_img : array (image) representing the two-dimensional histogram 
;                 obtained from the two input images.
;
; Common blocks:
;
;      None
;
; Calls:
;
;      HIST_2D
;
; Description:
;
;      Returns a two-dimensional histogram created from two images. 
;
; Side effects:
;
;      None
;
; Notes:
;
;      When X/YLOG is specified, X/YHRANGE and X/YBIN are assumed to give 
;      the range of values and bin size, respectively, in logarithm space.
;
; Restrictions:
;
;      None
;
; Modification history:
;
;      V. Andretta,   2/Jul/1998 - Created (adapted from HIST2ROI)
;      V. Andretta, Oct-Nov/1998 - Revised
;
; Contact:
;
;      VAndretta@solar.stanford.edu
;-
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;

  function MAKE_HIST2D,image1,image2,MISSING=in_missing $
                      ,XLOG=xlog        ,YLOG=ylog         $
                      ,XHRANGE=in_xrange,YHRANGE=in_yrange     $
                      ,XBIN=xbin        ,YBIN=ybin         $
                      ,INFO=hist_info   ,IMAGES=hist_input

;%%% Check input

  ON_ERROR,2

  hist_img=[-1]

;%%%%% Check input arrays

  if N_ELEMENTS(image1) eq 0 or N_ELEMENTS(image2) eq 0 then begin
    PRINT,'%E> MAKE_HIST2D: Give 2 images (or set of images)'
    RETURN,hist_img
  endif
  x=image1
  y=image2
  x_size=SIZE(x) & x_dims=x_size(1:x_size(0)) & x_elems=x_size(x_size(0)+2)
  y_size=SIZE(y) & y_dims=y_size(1:y_size(0)) & y_elems=y_size(y_size(0)+2)
;%Relax!
;%if N_ELEMENTS(x_dims) ne N_ELEMENTS(y_dims) or $
;%   MAX(x_dims ne y_dims) then begin
;%  PRINT,'%E> MAKE_HIST2D: Images must have the same dimensions'
;%  RETURN,hist_img
;%endif
  if x_elems ne y_elems then begin
    PRINT,'%E> MAKE_HIST2D: Images must have the same number of elements'
    RETURN,hist_img
  endif
  x=FLOAT(x)
  y=FLOAT(y)


;%%% Flags for missing/bad points

  if N_ELEMENTS(in_missing) gt 0 then missing=in_missing(0) $
                               else missing=MIN([-100,MIN(x)-1,MIN(y)-1])
  x_inf=WHERE(FINITE(x) eq 0) & if x_inf(0) ge 0 then x(x_inf)=missing
  y_inf=WHERE(FINITE(y) eq 0) & if y_inf(0) ge 0 then y(y_inf)=missing
  if (WHERE(x ne missing))(0) lt 0 or (WHERE(y ne missing))(0) lt 0 then begin
    PRINT,'%E> MAKE_HIST2D: Not enough good points to make an histogram'
    RETURN,hist_img
  endif


;%%% Compute logarithm if requested

  if KEYWORD_SET(xlog) then begin
    r_pos=WHERE(x gt 0 and x ne missing,N_pos)
    r_neg=WHERE(x le 0  or x eq missing,N_neg)
    if N_pos gt 0 then x(r_pos)=ALOG10(x(r_pos))
    if N_neg gt 0 then x(r_neg)=missing
  endif
  if KEYWORD_SET(ylog) then begin
    r_pos=WHERE(y gt 0 and y ne missing,N_pos)
    r_neg=WHERE(y le 0  or y eq missing,N_neg)
    if N_pos gt 0 then y(r_pos)=ALOG10(y(r_pos))
    if N_neg gt 0 then y(r_neg)=missing
  endif
  xgood=WHERE(x ne missing,Nxgood)
  ygood=WHERE(y ne missing,Nygood)
  if Nxgood eq 0 or Nygood eq 0 then begin
    PRINT,'%E> MAKE_HIST2D: Not enough good points to make an histogram'
    RETURN,hist_img
  endif


;%%% Histogram range

  x_min=MIN(x(xgood),MAX=x_max)
  if N_ELEMENTS(in_xrange) eq 2 then begin
    if TOTAL(FINITE(in_xrange)) eq 2 then $
      x_min=MIN(in_xrange,MAX=x_max) $
    else $
      PRINT,'%W> MAKE_HIST2D: XHRANGE contains illegal floating values. ' $
           +'Ignored.'
  endif else begin
    if N_ELEMENTS(in_xrange) gt 0 then $
      PRINT,'%W> MAKE_HIST2D: XHRANGE must have two elements. Ignored.'
  endelse
  x_min=FLOAT(x_min)
  x_max=FLOAT(x_max)

  y_min=MIN(y(ygood),MAX=y_max)
  if N_ELEMENTS(in_yrange) eq 2 then begin
    if TOTAL(FINITE(in_yrange)) eq 2 then $
      y_min=MIN(in_yrange,MAX=y_max) $
    else $
      PRINT,'%W> MAKE_HIST2D: YHRANGE contains illegal floating values. ' $
           +'Ignored.'
  endif else begin
    if N_ELEMENTS(in_yrange) gt 0 then $
      PRINT,'%W> MAKE_HIST2D: YHRANGE must have two elements. Ignored.'
  endelse
  y_min=FLOAT(y_min)
  y_max=FLOAT(y_max)



;%%% Binning parameters. Note that if X/YLOG has been specified, 
;%%% the input X/YBIN value will specify the binning in logarithm.
;%%% Default values for bin sizes are of the form 0.5*10.^N, 10.^N or 
;%%% 2.*10^N, where N is some integer, so that the entire data range is 
;%%% covered by a number of bins close to 64. 

  Nh_def=64
  binfac=[0.5,1.0,2.0]
  epsilon=1.d-6

;%x_bin_def=(x_max-x_min)/128.*(1+epsilon)
  x_bin_def=10.^ROUND(ALOG10((x_max-x_min)/Nh_def))
  df=ABS((x_max-x_min)/x_bin_def/binfac-Nh_def)
  x_bin_def=x_bin_def*binfac((WHERE(df eq MIN(df)))(0))
;%x_bin_def=x_bin_def*(1+epsilon)

;%y_bin_def=(y_max-y_min)/128.*(1+epsilon)
  y_bin_def=10.^ROUND(ALOG10((y_max-y_min)/Nh_def))
  df=ABS((y_max-y_min)/y_bin_def/binfac-Nh_def)
  y_bin_def=y_bin_def*binfac((WHERE(df eq MIN(df)))(0))
;%y_bin_def=y_bin_def*(1+epsilon)

  if N_ELEMENTS(xbin) gt 0 then x_bin=xbin(0) else x_bin=x_bin_def
  if x_bin le 0 then begin
    PRINT,'%W> MAKE_HIST2D: X bin size is zero or negative. Ignored.'
    x_bin=x_bin_def
  endif
  if N_ELEMENTS(ybin) gt 0 then y_bin=ybin(0) else y_bin=y_bin_def
  if y_bin le 0 then begin
    PRINT,'%W> MAKE_HIST2D: Y bin size is zero or negative. Ignored.'
    y_bin=y_bin_def
  endif


;%%% Since HIST_2D requires an array of non negative integers, 
;%%% we must scale input images and add the appropriate offset. 
;%%% Bad values are shelved in a corner of the scaled arrays, and will 
;%%% later be eliminated from the histogram.
;%%% N.B.: No need to check for infinities or NaN values here because 
;%%% the x and y array have already been 'purged', and the bin sizes 
;%%% have been verified not to be negative or null. 

  r=WHERE(x eq missing or x lt x_min or x gt x_max,N)
  ix=ROUND(((x>x_min)<x_max)/x_bin)
  ix_min=MIN(ix)
  ix=1+ix-ix_min
  x_zero=ix_min*x_bin
  if N gt 0 then ix(r)=0     ; Assign the value 0 to bad/missing pixels

  r=WHERE(y eq missing or y lt y_min or y gt y_max,N)
  iy=ROUND(((y>y_min)<y_max)/y_bin)
  iy_min=MIN(iy)
  iy=1+iy-iy_min
  y_zero=iy_min*y_bin
  if N gt 0 then iy(r)=0     ; Assign the value 0 to bad/missing pixels


;%%% Compute 2D histogram

  h=HIST_2D(ix,iy)  ;,MAX1=ix_max,MAX2=iy_max)
  sz=SIZE(h)
  Nh_x=sz(1)        ; = 1st dimension of array
  Nh_y=sz(2)        ; = 2nd dimension of array
  if Nh_x le 1 or Nh_y le 1 then begin
    PRINT,'%E> MAKE_HIST2D: Not enough good points to make a 2-D histogram'
    RETURN,hist_img
  endif
  h=h(1:*,*) & h=h(*,1:*)  ; Eliminate histogram bins containing bad points
  Nh_x=Nh_x-1
  Nh_y=Nh_y-1


;%%% Create output structures

  hist_img=TEMPORARY(h)

  hist_info=REPLICATE({dim: 0L , zero: 0.0 , bin: 0.0, log: 0},2)
  hist_info.dim=[Nh_x,Nh_y]
  hist_info.zero=[x_zero,y_zero]
  hist_info.bin=[x_bin,y_bin]
  hist_info.log=[KEYWORD_SET(xlog),KEYWORD_SET(ylog)]

  if N_ELEMENTS(hist_input) ne 0 then begin
    hist_input=REPLICATE({flt: TEMPORARY(x) , int: TEMPORARY(ix)},2)
    hist_input(1).flt=TEMPORARY(y)
    hist_input(1).int=TEMPORARY(iy)
  endif


;%%% Return

  RETURN,hist_img
  end
