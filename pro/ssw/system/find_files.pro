;+
; Project     : SOHO - CDS     
;                   
; Name        : FIND_FILES
;               
; Purpose     : Find multiple files in a multiple path
;               
; Explanation : FIND_FILES splits the supplied PATHS string by calling
;               FIND_ALL_DIR and then loops over all paths calling FIND_FILE()
;               with each path plus the file specification, returning the full
;               list of matching files. The supplied file specification may
;               contain standard wildcard characters.
;               
; Use         : filelist = FIND_FILES(FILE_SPEC,PATHS)
;    
; Inputs      : FILE_SPEC: File specification, e.g., "s*r00.fits". Should
;                          *not* contain any path. Scalar string.
;               
;               PATHS: Scalar string containing one or more default paths to
;                      search for files matching the file specification. See
;                      FIND_ALL_DIR for a more detailed description. The
;                      current directory is NOT searched.
;
; Opt. Inputs : None.
;               
; Outputs     : Returns a string array with full path names of each file
;               matching the file specification. If no files are found
;               an empty string is returned.
;               
; Opt. Outputs: None.
;               
; Keywords    : None.
;
; Calls       : CONCAT_DIR(), FIND_ALL_DIR(), FIND_FILE(), PARCHECK, TYP()
;
; Common      : None.
;               
; Restrictions: Mmmm?
;               
; Side effects: None known.
;               
; Category    : Utilities, Operating_system
;               
; Prev. Hist. : Multi-path CDS_FITS_DATA created a need for it.
;
; Written     : SVH Haugan, UiO, 23 April 1996
;               
; Modified    : Version 2, 6 August 1996
;                       Using find_all_dir for +/dir expansion, and using
;                       concat_dir in an attempt to be portable.
;               16 May 2006, Zarro (L-3Com/GSFC) - added temporary()
;-            

FUNCTION find_files,file_spec,paths
  
  IF N_PARAMS() LT 2 THEN BEGIN
     MESSAGE,"Use : filelist = find_files(file_spec,paths)"
  END
  
  parcheck,file_spec,1,typ(/str),0,'FILE_SPECIFICATION'
  parcheck,paths,1,typ(/str),0,'PATHS'
  
  allpaths = find_all_dir(paths,/plus_required)
  
  FOR i = 0,N_ELEMENTS(allpaths)-1 DO BEGIN
     newfiles = find_file(concat_dir(allpaths(i),file_spec))
     IF newfiles(0) NE '' THEN BEGIN
        IF N_ELEMENTS(files) EQ 0 THEN files = newfiles  $
        ELSE                           files = [temporary(files),temporary(newfiles)]
     END
  END
  IF N_ELEMENTS(files) EQ 0 THEN RETURN,''
  RETURN,files
  
END


