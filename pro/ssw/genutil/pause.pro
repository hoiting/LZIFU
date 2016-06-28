pro pause, quiet=quiet, force=force, ring=ring
;+
; Project     :	SOHO
;
; Name        :	PAUSE
;
; Purpose     :	Request that the user hit <CR> between plots.
;
; Category    :
;
; Explanation :	Use this procedure to request that the user hit <CR> between
;		plots.  Ignored if the output device is Postscript or other
;		printer, or the Z-buffer.
;
;		If a "q" or "Q" is entered at the "Pause" prompt, then the
;		program stops within the calling procedure (useful for
;		debugging).
;
;		If an "e" or "E" is entered at the "Pause" prompt, then exit
;		completely, and return to the main level.
;
; Syntax      :	PAUSE  [, /QUIET ]  [, /FORCE ]  [, /RING ]
;
; Examples    :
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	QUIET	= If set, then the word "Pause" is not written to the
;			  terminal.
;
;		FORCE	= If set, then force a pause, even if the graphics
;			  device is a printer.
;
;		RING	= Ring the terminal bell the number of times indicated
;			  by its value, or use /RING to ring once.
;
; Calls       :	BELL
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Written 1991 by M.Morrison
;		5-Nov-96 (MDM) - Added documentation header
;		Version 3, 17-Feb-1998, William Thompson, GSFC
;			More graceful exit when Q key is pressed.
;			Use get_kbrd instead of read.
;			Allow "E"xit option.
;		Version 4, 02-Mar-1998, William Thompson, GSFC
;			Don't use GET_KBRD in Windows--doesn't recognize
;			carriage returns.
;		Version 5, 1998 Mar 02, Roger J. Thomas, GSFC  (Add /RING)
;
; Contact     :	MMORRISON
;-
;
on_error, 2
;
;  If the device is a printer, graphics file, or the Z-buffer, then take no
;  action.
;
if have_windows() or (!d.name eq 'TEK') or (!d.name eq 'REGIS') or	$
	keyword_set(force) then begin
    in=' '
    if keyword_set(ring) then bell,ring
    if os_family() eq 'Windows' then begin
	if keyword_set(quiet) then read, '', in else read, 'Pause', in
    end else begin
	if not keyword_set(quiet) then print,'Pause'
	in = get_kbrd(1)
    endelse
;
;  If the Q key is pressed, then cause an error and return and stop.
;
    if (strupcase(in) eq 'Q') then message, 'Stopping in calling routine'
;
;  If the E key is pressed, then return to the main level.
;
    if (strupcase(in) eq 'E') then begin
	message, 'Returning to main level', /continue
	retall
    endif
endif

end

