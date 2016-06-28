PRO SELECT_X, selections, iselected, comments, command_line, only_one
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	SELECT_X
; Purpose     :	
;	Allos interactive screen selection from X-windows device.
; Explanation :	
;	Routine to allow a user to make an interactive screen selection
;	from a list (array) of strings.  This assumes an x-windows device.
;
; Use         :	
;	select_x, selections, iselected, comments, command_line, only_one
;
; Inputs      :	
;	selections - string array giving list of items that can be
;		selected.
;
; Opt. Inputs :	
;	comments - comments which can be requested for each item in
;		array selections.  It can be:
;		string array - same length as array selections.
;		null string - no comments available
;		scalar string - name of a procedure which will
;			return comments.  It will take selections
;			as its first argument and return comments
;			as its second argument.
;	command_line - optional command line to be placed at the bottom
;		of the screen.  It is usually used to specify what the
;		user is selecting.
;	only_one - integer flag. If set to 1 then the user can only select
;		one item.  The routine returns immediately after the first
;		selection is made.
;
; Outputs     :	
;	iselected - list of indices in selections giving the selected
;		items.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	READ_KEY
;
; Common      :	None.
;
; Restrictions:	
;	The screen must be X-windows compatible.
;	As of Mar 91, the comments option does not appear to be working
;
; Side effects:	
;	!err is set to the number of selections made
;
;	A window is opened and closed.
;
; Category    :	Utilities, User_interface
;
; Prev. Hist. :	
;	version 1, D. Lindler  April 88.
;	modified to IDL V2 (from screen_select).  M. Greason, May 1990.
;	Changed name from screen_select_x         W. Landsman  January 1993
;	Removed RETAIN = 2, not needed 		  W. Landsman May 1993
;
; Written     :	D. Lindler, GSFC/HRS, April 1988
;
; Modified    :	Version 1, William Thompson, GSFC, 29 March 1994
;			Incorporated into CDS library
;
; Version     :	Version 1, 29 March 1994
;-
;
;--------------------------------------------------------------------------
;			set defaults
;
IF n_params(0) LT 3 THEN comments=''
IF n_params(0) LT 4 THEN command_line=''
IF n_params(0) LT 5 THEN only_one=0
;
; 			initilization
;
n_select = 0			;number of selections made
n = n_elements(selections)
nchar = max(strlen(selections))
help_avail = 0			;help available flag
ncom = 0				;Length of comments
IF n_elements(comments) EQ n THEN BEGIN
	ncom = max(strlen(comments))
	help_avail = 1
ENDIF
IF n_elements(comments) EQ 1 THEN BEGIN				;scalar string
	IF strlen(strtrim(comments)) GT 0 THEN help_avail=1	;function name
ENDIF
question=0			;user asked for help
get_lun,unit
openw,unit,filepath(/TERMINAL)		;open terminal for output
;
; 			print help lines in the text window.
;
message='Use arrow keys to move.  '
IF only_one THEN message=message+'<cr> or <space bar> to select' $
	    ELSE message=message+'<space bar> to select.  <cr> when done. ' + $
                 '"R" to reset'
;IF help_avail THEN message=message+'  ? for info.'
printf,unit,message
printf,unit,command_line
;
; 			determine screen format
;
inpos = 0
spos = 0
dx = 9 & dy = 20				;char. size, in pixels.
totpix = ((nchar+ncom*question+3)*dx) < 750	;total pixels required
nx = 750 / totpix				;number in x direction
ny = (n+nx-1)/nx				;total number in y direction
screen=strarr(nx,ny)				;fill display string array.
selected = replicate(0B,nx,ny)			;vector of selected values
k = 0
FOR j = 0, ny-1 DO BEGIN
	FOR i = 0, nx-1 DO BEGIN
		IF (k LT n) THEN BEGIN
			st=selections(k)
			IF (ncom GT 0) AND (question EQ 1) THEN $
				st=' '+st+' '+comments(k)
			screen(i,j)=st
		ENDIF ELSE screen(i,j) = "  "
		k = k + 1
      	ENDFOR
ENDFOR
nlines = (800 / dy) < ny		;number of screen lines to display
nscr = (ny + nlines - 1) / nlines	;number of screens to display.
xpos = indgen(nx) * totpix + 5
ypos = reverse(indgen(nlines)) * dy + 5
;
; 			screen format init.
;
if !VERSION.OS EQ "vms" then cr = 13B else cr = 10B
up = 128B
down = 130B
left = 129B
right = 131B
ix=0				;current position on screen
iy=0
xf = 1
yf = 3
iscr = 0
xsz = xpos(nx-1) + totpix + 5	;open window.
ysz = ypos(0) + dy + 5
window, 9, /free,xsize=xsz,ysize=ysz,xpos=100,ypos=860-ysz,title=" "
wi = !d.window
xpb = [0, totpix-1, totpix-1, 0, 0]
ypb = [0, 0, dy-1, dy-1, 0]
refresh:
polyfill, [0,!d.x_size-1,!d.x_size-1,0,0],[0,0,!d.y_size-1,!d.y_size-1,0],$
	/device,color=255
;
; 			print initial contents of the screen
;
FOR j = 0, nlines-1 DO BEGIN
	k = j + spos
	FOR i = 0, nx-1 DO BEGIN 
		IF k LT ny THEN BEGIN
 		   IF selected(i,k) THEN BEGIN
			polyfill, xpb+xpos(i), ypb+ypos(j), /device,color=80
			xyouts, xpos(i)+xf, ypos(j)+yf, screen(i,k), $
				/device,color=255,size=2
          	   ENDIF ELSE xyouts, xpos(i)+xf, ypos(j)+yf, screen(i,k), $
				/device,color=0,size=2
		ENDIF
	ENDFOR
ENDFOR
;
; 			loop until <cr>
;
key= 0B
WHILE key NE cr DO BEGIN
;
; 			high light current location
;
	polyfill, xpb+xpos(ix), ypb+ypos(iy), /device,color=80
	xyouts, xpos(ix)+xf, ypos(iy)+yf, screen(ix,iy+spos), $
		/device,color=255,size=2
        wait,0.1
;
; 			process next key
;
	key = read_key(1)
;
; 			arrow key processing
;
	IF (key EQ up) OR (key EQ down) OR (key EQ right) OR (key EQ left) $
	    THEN BEGIN
	    scroll=0					;scroll flag
	    IF NOT selected(inpos) THEN BEGIN		;unhighlight pos.
                polyfill, xpb+xpos(ix), ypb+ypos(iy), /device,color=255
                xyouts, xpos(ix)+xf, ypos(iy)+yf, screen(ix,iy+spos), $
                    /device,color=0,size=2
            ENDIF ELSE BEGIN
                polyfill, xpb+xpos(ix), ypb+ypos(iy), /device,color=80
                xyouts, xpos(ix)+xf, ypos(iy)+yf, screen(ix,iy+spos), $
                    /device,color=255,size=2
	    ENDELSE
	    CASE key OF
		up: BEGIN
			IF iy GT 0 THEN BEGIN
				iy = iy - 1
				inpos = inpos - nx
		    	ENDIF ELSE BEGIN
				IF iscr GT 0 THEN BEGIN
				    iscr = iscr - 1
				    scroll = 1
				ENDIF
			ENDELSE
		    END
		down: BEGIN
			IF (iy LT (nlines-1)) AND ((iy+spos) LT (ny-1)) $
			THEN BEGIN
				inpos=inpos+nx
				iy=iy+1
			ENDIF ELSE BEGIN
				IF iscr LT (nscr - 1) THEN BEGIN
				    iscr = iscr + 1
				    scroll = 1
				ENDIF
			ENDELSE
		     END
		right: BEGIN
 			 IF ix LT (nx-1) THEN BEGIN
				ix=ix+1
				inpos=inpos+1
			 ENDIF
		       END
		left : BEGIN
			 IF ix GT 0 THEN BEGIN
				ix=ix-1
				inpos=inpos-1
			 ENDIF
		       END
	    ENDCASE
	    WHILE inpos GE n DO BEGIN		;prevent passing end-of-list
		inpos=inpos-1
		ix=ix-1
	    ENDWHILE
;
; 			do we need to scroll ?
;
		IF scroll THEN BEGIN
			iy = 0
			spos = iscr * nlines
			inpos = (nx * spos) + ix
			goto, refresh
		ENDIF
	ENDIF
;
; 			process other keys
;
	IF (only_one EQ 1) AND (key EQ cr) THEN key=' '	;select with cr also
	   if string(key) EQ ' ' THEN BEGIN
		    IF (NOT selected(inpos)) THEN BEGIN
			selected(inpos)=1B
			n_select=n_select+1
                        IF n_select EQ 1 THEN iselected = lonarr(1) +inpos $
                                         ELSE iselected = [iselected,inpos]
			IF only_one THEN BEGIN		;got our one selection?
                                iselected = iselected(0)
				goto,done
			ENDIF
		    ENDIF
            ENDIF
	CASE strupcase(key) OF
	    cr  : goto,done
	    'R' : BEGIN
			selected(inpos)=0B
			n_select = (n_select - 1) > 0
		  END
	    '?' : BEGIN
		   IF (help_avail) THEN BEGIN
			IF (ncom EQ 0) THEN BEGIN  ;go get help text
			    printf,unit,'PLEASE WAIT....'
			    istat=execute(comments+',selections,comments')
			    ncom=strlen(comments(0))
			    printf,unit,'FINISHED WITH HELP'
			ENDIF
			question=1
		   ENDIF
	          END
	    ELSE :
	ENDCASE
ENDWHILE
;
;			Finished.  Close the window and the output device.
;			Set !err to the number of items selected.
;
done:
wdelete, wi
free_lun,unit
!err=n_select
;
RETURN
END
