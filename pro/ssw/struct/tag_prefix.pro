;---------------------------------------------------------------------------
; Document name: tag_prefix.pro
; Created by:    Andre Csillaghy, June 28, 2001
;
; Last Modified: Fri Nov 22 13:02:56 2002 (csillag@soleil.cs.fh-aargau.ch)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       TAG_PREFIX()
;
; PURPOSE: 
;       Appends or removes a prefix and optionally a potfix to the tag
;       names of a  structure. 
;
; CATEGORY:
;       gen / struct
; 
; CALLING SEQUENCE: 
;       out_struct = tag_prefix( struct, prefix )
;
; INPUTS:
;       struct: the structure for which tag names must be modified
;       prefix: the prefix to append, a string or string array
;
; OUTPUTS:
;       out_struct: a structure with the modified tag names. The
;                   prefix is separated from the original tag nem with
;                   an underscore "_". 
;
; KEYWORDS: 
;       REMOVE; if set, the prefix is removed from the
;       tag names. The prefix will be removed up to and with the
;       underscore "_"
;
; RESTRICTIONS: 
;       With the REMOVE keyword, the prefix and postfix must be scalar strings
;
; EXAMPLES:
;       IDL> struct = { a: 0.0, b: indgen(10), c: 0L }
;       IDL> new_struct=  tag_prefix( struct, 'hello' )      
;       IDL> help, new_struct, /str
;       ** Structure <851006c>, 3 tags, length=28, data length=28, refs=1:
;          HELLO_A         FLOAT           0.00000
;          HELLO_B         INT       Array[10]
;          HELLO_C         LONG                 0
;       IDL> help, tag_prefix( struct, 'hell', /remove ), /str
;       ** Structure <844ebec>, 3 tags, length=28, data length=28, refs=2:
;          A               FLOAT           0.00000
;          B               INT       Array[10]
;          C               LONG                 0
;
; SEE ALSO:
;       Rep_Tag_Name
;
; HISTORY:
;       Version 1, June 28, 2001, 
;           A Csillaghy, csillag@ssl.berkeley.edu
;       26-May-2003, Kim Tolbert - change StrSplit to SSW_StrSplit
;       27-May-2003, Kim Tolbert - change trup to strup
;-
;


FUNCTION tag_prefix, struct, prefix, ADD=add, REMOVE=remove

tags = Tag_Names( struct )
new_name = tags
prefix = strup( prefix )

IF Keyword_Set( REMOVE ) THEN BEGIN
    pos = Strpos( tags, Strupcase( prefix ) )
    list = Where( pos EQ 0, count )
    IF count NE 0 THEN BEGIN 
        new_name[list] = SSW_StrSplit( new_name[list], prefix + '_', /TAIL )
    ENDIF 
ENDIF ELSE BEGIN  
    pos = Strpos( tags, prefix )
    list = Where( pos NE 0, count )
    IF count NE 0 THEN BEGIN 
        new_name[list] = prefix + '_' + new_name[list]
    ENDIF 
ENDELSE 
new_struct = struct

n_tag = N_Elements( tags )
FOR i=0, n_tag-1 DO BEGIN 
    new_struct = Rep_Tag_Name( new_struct, tags[i], new_name[i] ) 
ENDFOR 

RETURN, new_struct

END


;---------------------------------------------------------------------------
; End of 'tag_pre_post_fix.pro'.
;---------------------------------------------------------------------------
