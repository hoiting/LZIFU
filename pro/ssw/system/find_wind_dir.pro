function find_wind_dir, root, spawn=spawn
;+
; Project     :	HESSI
;
; Name        :	FIND_WIND_DIR()
;
; Purpose     :	Finds all directories under a specified directory under windows.
;
; Explanation :	This routines finds all the directories in a directory tree
;		when the root of the tree is specified.  This provides the same
;		functionality as having a directory with a plus in front of it
;		in the environment variable IDL_PATH.
;
; Use         :	Result = FIND_WITH_DIR( PATH )
;
;		PATHS = FIND_WITH_DIR('+mypath')
;
; Inputs      :	PATH	= The path specification for the top directory in the
;			  tree.  Optionally this may begin with the '+'
;			  character but the action is the same.
;
;
; Opt. Inputs : None
;
; Outputs     :	The result of the function is a list of directories starting
;		from the top directory passed and working downward from there.
;		This will be a string array with one directory per
;		array element.
;
; Opt. Outputs:	None.
;
; Keywords    :	SPAWN - use win_spawn command.
;
; Calls       :	STR_LASTPOS
;
; Common      :	None.
;
; Restrictions:	PATH must point to a directory that actually exists.
;
;
;
; Side effects:	None.
;
; Category    :	Utilities, Operating_system.
;
; Prev. Hist. :	None.
;
; Written     :	Richard.Schwartz@gsfc.nasa.gov 27-May-1998.
;
; Modified    :	Version 1, Richard.Schwartz@gsfc.nasa.gov 27-May-1998.
;		Version 2, Richard.Schwartz,
;		Improved the speed by extracting last position characters
;		using byte arrays.
;
; Version     :	Version 1, 17 May 1998
;				Version 2, 17 Aug 1998
;-
;
	ON_ERROR, 2
;
	IF N_PARAMS() NE 1 THEN MESSAGE,	$
		'Syntax:  Result = FIND_WITH_DIR( PATH )'

if keyword_set( spawn ) then begin
	win_spawn, 'dir '+root+ '/ad /s /b', path
	return, path
	endif
;
; Find all the directories in the tree starting from the root directory
;
current = [root,'']
path = root
test = current(0)

while test ne '' do begin

	current = current(1:*)

	branches = findfile(concat_dir(test,'*'),count=nfile)
	byt_brnch= byte(branches)
	ncols    = n_elements( byt_brnch(*,0) )
	length   = strlen( branches )
	wlast    = lindgen(nfile)*ncols + length-1

	wbranch  = (where( byt_brnch(wlast) eq 92b )) ;last character a '\'

	wbranch2  = where( byt_brnch(wlast(wbranch)-1) ne 46b, nbranch) ;2nd last not a '.'
	if nbranch ge 1 then begin
		wbranch = wbranch(wbranch2)
		path = [path, branches(wbranch)]
		current = [branches(wbranch),current]
		endif

	test = current(0)
	endwhile

return, path
end
