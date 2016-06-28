PRO hit_any_key, NoPrompt=noprompt
;+
; $Id: hit_any_key.pro,v 1.1 2006/04/11 15:55:18 antunes Exp $
;
; Project   : developer area for STEREO SECCHI
;                   
; Name      : hit_any_key.pro
;               
; Purpose   : hit_any_key
;               
; Explanation: Requires user to hit a key to proceed with code
;               
; Use       : IDL> hit_any_key()
;    
; Inputs    : none
;               
; Outputs   : none
;
; Keywords  : NoPrompt : if set, does not tell user to hit a key
;
; Calls from LASCO : none 
;
; Common    : none 
;               
; Restrictions: none
;               
; Side effects: IDL halts until user hits any key
;               
; Category    : IO
;               
; Prev. Hist. : from the web
;
; Written     : unknown, imported by Sandy Antunes, NRL, Nov-Dec 2005
;               
; $Log: hit_any_key.pro,v $
; Revision 1.1  2006/04/11 15:55:18  antunes
; Massive re-org of cvs 'dev' preparatory to moving into solarsoft.
;
; Revision 1.3  2005/12/27 17:48:24  antunes
; Commented half of the routines using SSW style.  Also added a new
; axes test case 'arrowcube'.
; Checked in the Tomography/old/mikic_img.pro routine here because it
; is a dependency for the general image-prep routine 'get_timage.pro'
;
;-            
; found via google in Oct 2005 by Sandy Antunes    



    ; Clear typeahead buffer before input
    WHILE Get_KBRD(0) do junk=1

    ; Get input
    IF Keyword_Set(noprompt) THEN BEGIN
        junk = Get_KBRD(1)
    ENDIF ELSE BEGIN
        Print, 'Hit any key to continue (or Q to exit)...'
        junk = Get_KBRD(1)
	if (junk eq 'Q') then begin
	   print,'Stopping now.'
	   stop,''
	end
        Print, 'Continuing...
    ENDELSE

    ; Clear typeahead buffer after input
    WHILE Get_KBRD(0) do junk=1

    END

