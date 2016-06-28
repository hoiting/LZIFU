	FUNCTION FIND_ALL_DIR, PATH, _ref_extra=extra
;
; Name        :	FIND_ALL_DIR
;
; Purpose     :	Finds all directories under a specified directory.
;
; Explanation :	This routines finds all the directories in a directory tree
;		when the root of the tree is specified.  This provides the same
;		functionality as having a directory with a plus in front of it
;		in the environment variable IDL_PATH.
;
; Use         :	Result = FIND_ALL_DIR( PATH )
;
;		PATHS = FIND_ALL_DIR('+mypath', /PATH_FORMAT)
;		PATHS = FIND_ALL_DIR('+mypath1:+mypath2')
;
; Inputs      :	PATH	= The path specification for the top directory in the
;			  tree.  Optionally this may begin with the '+'
;			  character but the action is the same unless the
;			  PLUS_REQUIRED keyword is set.
;
;			  One can also path a series of directories separated
;			  by the correct character ("," for VMS, ":" for Unix)
;
; Outputs     :	The result of the function is a list of directories starting
;		from the top directory passed and working downward from there.
;		Normally, this will be a string array with one directory per
;		array element, but if the PATH_FORMAT keyword is set, then a
;		single string will be returned, in the correct format to be
;		incorporated into !PATH.
;
; Keywords    :	PATH_FORMAT	= If set, then a single string is returned, in
;				  the format of !PATH.
;
;		PLUS_REQUIRED	= If set, then a leading plus sign is required
;				  in order to expand out a directory tree.
;				  This is especially useful if the input is a
;				  series of directories, where some components
;				  should be expanded, but others shouldn't.
;
; Category    :	Utilities, Operating_system.
;
; Written     :	William Thompson, GSFC, 3 May 1993.
;
; Modified    :	Renamed to FIND_ALL_DIR2 to call EXPAND_DIRS
;-

        return,expand_dirs(path,_extra=extra)
        end
