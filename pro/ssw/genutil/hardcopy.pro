pro hardcopy, image, red, green, blue, bin=bin, file=file, black=black, $
	landscape=landscape, xsize=xsize, xpos=xpos, ypos=ypos, color=color, $
	noprint=noprint, noprompt=noprompt
;+
;NAME:
;	hardcopy
;PURPOSE:
;	Dump an 'X' window screen display to the hardcopy laser
;	printer.  The default is to use black and white.   PPRINT
;	is used to determine the print queues.
;CALLING SEQUENCE:
; 	hardcopy		; Default is black/white printer
;	hardcopy,/black		; Send to black/white printer
;	hardcopy,/color		; Send to color printer
;	hardcopy,/landscape	; Rotate to landscape on output
;	hardcopy,xsize=xsize	; Specify x size in inches (def=7. inches)
;
;	hardcopy,image		; Image must be a 2-d array
;	hardcopy,image,r,g,b,/color
;OPTIONAL INPUTS:
;	image	= 2-d Array to plot (doesn't read screen in this case)
;	Red	= Red color vector
;	Green	= Green color vector
;	Blue	= Blue color vector
;
;OPTIONAL INPUT KEYWORDS:
;	bin	- If the display was made by expanding the raw
;		  data using "REBIN", it is advised to pass that
;		  binning factor to this routine.  It will reduce
;		  the resolution by that fact before sending the
;		  data to the printer which will speed it up
;		  considerably.
;	file	- The name of the IDL output postscript file.  If
;		  absent, it will create the file on your root
;		  directory with file name "idl.ps"
;	black	- If present, print if black and white and send
;		  output to "isass0 lp0"
;  	landscape - Rotate the output into landscape mode
;	xsize	- Specify the x size (of the plot - even in landscape mode)
;		    in inches.  Default = 7 inch
;	xpos,ypos - Origin of the plot.  Default = 0.5 inch
;METHOD:
;	The routine checks the size of the window and does a TVRD
;	to get what is on the screen.  It is advisable to make the
;	screen just the size of your output item.  If the data is
;	over 256 pixels in either dimension, it asks if it can reduce
;	the resolution of the image dump to speed up the printing
;	to the laser printer.
;HISTORY:
;	Written 20-Oct-91 by M.Morrison
;	 9-Nov-92 (MDM) - Modified to use CONGRID instead of REBIN
;			  to get rid of the integer multiple problem.
;	18-nov-92 (JRL) - Fixed the a bug with setting xsiz and ysiz
;	16-apr-93 (JRL) - Added the landscape option
;	21-apr-93 (JRL) - Added the xsize, xpos, ypos keywords
;	13-may-93 (JRL) - Force color=0 for /black option. Make /black the
;			  default. 
;	19-may-93 (JRL) - Fix x offset for color option.
;	 6-Oct-93 (MDM) - Modified to use PPRINT instead of PR_PLASER
;	 8-Oct-93 (MDM) - Incorporated GLS filename fix (it was only an
;			  error in the PPRINT call)
;	 5-Nov-93 (SLF) - add noprint keyword and ys_noprint env
;       16-feb-95 (SLF) - andd NOPROMPT keyword non-interactive runs
;	 6-Oct-95 (JRL) - For /black option, if the color table is a
;			  grey-scale (i.e., red=green=blue), then use 
;			  tv,red(dump).  This will make user-defined gamma
;			  changes and effective.
;			  Always the restore the input !d.name upon exit.
;-
;
;TODO - add option /NORESET to not reset the plot device to 'x' ?
;
  save_device = !d.name		; Keep track of the device 
; Read the current IDL window:
if n_params() eq 0 then begin
  set_plot, 'X'		;make sure that we are reading from the screen
  xsiz = !d.x_size
  ysiz = !d.y_size
  dump = tvrd(0,0,xsiz,ysiz)
endif else begin
; User passed in the image to plot
  dump = image
  sz = size(dump)
  if sz(0) ne 2 then begin
      print,' **** Error in HARDCOPY  ****'
      print,'      Image array must 2-d'
      help,image
      return
  endif
  xsiz = sz(1) & ysiz = sz(2)
  tvlct,red_save,green_save,blue_save,/get	; Save the color table
  set_plot,'ps'
  if n_params() ge 4 then tvlct,red,green,blue
endelse

if (keyword_set(bin)) then dump = rebin(dump, xsiz/bin, ysiz/bin)
;
siz = size(dump)
nx = siz(1)
ny = siz(2)
prompt=1-keyword_set(noprompt)
if ((nx gt 256) or (ny gt 256)) and prompt then begin
    print, 'Image is quite large: ', nx, ' x ', ny
    xfact = fix( nx/256. + 0.5)
    yfact = fix( ny/256. + 0.5)
    fact = xfact>yfact
    input, 'Can we reduce the resolution by a factor of ' + strtrim(fact,2), in, 'Yes'
    yesno, in
    ;;if (in eq 1) then dump = rebin(dump, nx/fact, ny/fact)
    if (in eq 1) then dump = congrid(dump, nx/fact, ny/fact)
end
;
siz = size(dump)
nx = siz(1)
ny = siz(2)
if n_elements(xsize) ne 0 then begin
   xsiz = xsize
   ysiz = xsiz*float(ny)/float(nx)
endif else begin
  if (nx gt ny) then begin
    xsiz = 7.
    ysiz = xsiz*float(ny)/float(nx)
  end else begin
    ysiz = 7.
    xsiz = ysiz*float(nx)/float(ny)
  endelse
endelse
if n_elements(xpos) ne 0 then xoff = xpos else xoff = 0.5
if n_elements(ypos) ne 0 then yoff = ypos else yoff = 0.5

if  (xsiz gt 7.) or (ysiz gt 9.5) then begin
   tbeep & print,'**  Warning from Hardcopy  **'
   print,string('    Output plot size will be: ',xsiz,' by',ysiz,' inches', $
	format='(a,f5.1,a,f5.1,a)')
   input,'* Do you want to continue? ', ans, 'N'
   if strmid(strupcase(ans),0,1) ne 'Y' then return
endif

set_plot,'ps'                           ; Select new plotting device
device,/portrait			; Make sure we are in portrait mode

if keyword_set(landscape) then begin	; Setup landscape if required
  temp = xsiz				; Interchange x and y sizes
  xsiz = ysiz
  ysiz = temp
  dump = rotate(dump,3)			; Rotate to landscape position
endif 
  
;    
if n_elements(file) eq 0 then file_name = '~/idl.ps' else file_name = file
if keyword_set(color) then bw_color = 0 else bw_color = 1   ; 1 = b/w, 2 = color
if keyword_set(black) then bw_color = 1		; /black over-rides
if not keyword_set(color) and not keyword_set(black) then print,'*** Printing on black and white printer'
if bw_color then begin
    device, color=0, yoff=yoff, xoff=xoff, xsize=xsiz, ysize=ysiz,/inches,fil=file_name
    ;;dev = 'lp0'
;   Fold the image through the color table vector if a grey-scale color table has been defined:
    tvlct,rred,ggreen,bblue,/get		; Get the actually used table
    if min(rred-ggreen) + max(rred-ggreen) + min(rred-bblue) + max(rred-bblue) eq 0 then $
		dump = rred(dump) else begin
		message,'Current color table is not a grey-scale.',/info
		message,' -- Will use default PostScript color table.',/info
    endelse
end else begin
    device, /color, bits_per=8, yoff=yoff, xoff=xoff, xsize=xsiz, ysize=ysiz,/inches,fil=file_name
    ;;dev = ''
end
;
if n_params() eq 0 then reset = 1 else reset = 0 ;set plot device back to 'X' 
tv, dump
;;pr_plaser, file=file, dev=dev, reset = reset

if keyword_set(noprint) or get_logenv('ys_noprint') eq 1 then begin
   message,/info,'Automatic printing is disabled 
endif else pprint, file_name, dev=dev, reset = reset, color=color

set_plot,save_device				; Restore the device
if n_params() ge 1 then begin
  tvlct,red_save,green_save,blue_save
endif
;
end
