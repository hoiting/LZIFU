;+
; Name: text_output
;
; Purpose: Display ascii text on screen, send to printer, or save in file
;
; Calling sequence:
;	text_output, text [, show_text=show_text, print_text=print_text, file_text=file, group=group, err_msg=err_msg]
;
; Inputs:
;	text - string of text
;
; Input Keywords:
;	show_text - if set, then show text on screen in a text widget
;	print_text - if set, then create temporary file and print it
;	file_text - if set, ask user for output file name and write file.  Or alternatively, file_text may be the
;		name of the file (if no path will write in current directory)
;	group - group leader for text widget if show is selected
;   title - title of screen output text widget
;   queue - printer queue for print output
; Note:  If none of show_text, print_text, or file_text keywords are set, then show_text is automatically set.
;
; Output keywords:
;	filename - name of file that was written to, if any
;	err_msg - string error message returned if there was an error
;
; Written: 31-Jul-2000, Kim Tolbert
;
; Modifications:
;   3-Nov-2000, Kim - changed keyword names from show,print,file to show_text,print_text,file_text
;      to make them unique in cases where _extra is used in routines that call text_output
;   3-Dec-2000, Kim - added queue keyword
;   21-Jan-2001, Kim - added filename keyword.  And use message instead of print for filename.
;   29-Jan-2001, Kim - call dsp_strarr with /no_block
;   25-Mar-2001, Kim - Pass ysize on call to dsp_strarr
;	11-Aug-2002, Kim - Modified header documentation
;
;-

;----------------------------------------------------------------------------------------------------------------------------

pro text_output,  text, $
	show_text=show_text, $
	print_text=print_text, $
	file_text=file_text, $
	filename=filename, group=group, title=title, queue=queue, err_msg=err_msg

err_msg = ''

if not (keyword_set(show_text) or keyword_set(print_text) or keyword_set(file_text) ) then show_text=1

if keyword_set(show_text) then begin
	os = os_family()
	if os eq 'Windows' then font = 'fixedsys' else font = 'fixed'
	; open new widget to display lines
	if have_windows() then dsp_strarr, text, /no_block, font=font, $
		group=group, title=title, xsize=140, ysize=(n_elements(text) < 35)
endif

if keyword_set(file_text) then begin
	if size(file_text, /tname) eq 'STRING' then filename = file_text else begin
		cd, current=dir
		filename = dialog_pickfile (path=dir, filter='*.txt', $
			file='output.txt', $
			title = 'Select output file',  $
			group=group, $
			get_path=path)
		if filename eq '' then begin
			err_msg = 'No output file selected.'
			message, err_msg, /cont
			return
		endif
	endelse

	wrt_ascii, text, filename, err_msg=err_msg

	if err_msg eq '' then message,'Created file: ' + filename, /info

endif

if keyword_set(print_text)  then begin

	filename = 'temp.txt'

	; insert escape sequences in front of text in file to control print format
	; if max line length < 95, then print portrait, 14 chars/inch, 8 lines per inch
	; if >= 95, print landscape, 14 chars/inch
	; this may not work on some printers - may have to remove.  Does work on HP.
	if max(strlen(text)) lt 95 then ctrl_string = string(27b) + '(s14H' + string(27b) + '&l8D' else $
		ctrl_string = string(27b) + '&l1O' + string(27b) + '(s14H'

	wrt_ascii, [ctrl_string, text], filename, err_msg=err_msg

	if err_msg eq '' then begin

		doprint = 1
		if n_elements(text) gt 400 then begin
			if have_windows() then begin
				answer = xanswer ('Text is long - ' + strtrim(n_elements(text),2) + ' lines.  Are you sure you want to print?', /str, default=1)
				if answer eq 'n' then doprint=0
			endif
		endif

		if doprint then send_print, filename, queue=queue, qualifier='-h', /delete

	endif

endif

end