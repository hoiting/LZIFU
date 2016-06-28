;+
; $Id: cpp2idlstruct.pro,v 1.3 2005/05/19 19:08:42 nathan Exp $
;
; Project     : STEREO SECCHI
;                   
; Name        : CPP2IDLSTRUCT
;               
; Purpose     : To convert c++/.h format file to IDL include file.
;               
; Explanation : This routine reads in a file containing a C structure definition
;   	    	and converts it into an IDL structure definition file.
;               
; Use         : IDL> cpp2idlstruct, input_file_name, table_name
;    
; Inputs      : input_file_name		; file with C structure defintion
;               table_name		; specify the prefix of the output 
;   	    	    	include file: "table_name"_struct.inc
;               
; Outputs     : None.
;               
; Calls       : STR_SEP2, STR2ARR, ARR2STR, BREAK_FILE, SPEC_DIR
;
; Common      : None.
;               
; Restrictions: Must have write permission for the current directory.
;               
; Side effects: Creates one file in the current directory named:
;		structure_name_struct.inc	;IDL include file
;               
; Category    : Database, Pipeline 
;               
; Prev. Hist. : None.
;
; Written     : Nathan Rich, NRL/I2, Sep 2004
;               
; Modified    :
;
; $Log: cpp2idlstruct.pro,v $
; Revision 1.3  2005/05/19 19:08:42  nathan
; changes May 3 2005
;
; Revision 1.2  2005/02/02 16:17:28  nathan
; moved to new directory
;
; Revision 1.2  2005/01/31 19:32:31  nathan
; 2 not 3 arguments
;
; Revision 1.1  2004/09/12 02:25:30  nathan
; does not handle enum type definitions
;
;
;-            

;__________________________________________________________________________________________________________
;

FUNCTION line2words, DEBUG=debug
COMMON cpp_common, idl_out, in
; Reads next line in file and 
; only returns words from lines that are actual code
    	line = ''
    	start1:
	IF (EOF(in)) THEN return,'eof'
	READF, IN, line
	;print,line
	line = STRTRIM(line,2)
	cmntchk=strmid(line,0,2)
	;help,cmntchk
	IF ((cmntchk EQ "/*") OR (cmntchk EQ "**")) THEN BEGIN
	    IF (strmid(line,strlen(line)-2,2) EQ "*/") THEN $
	    goto, start1
	    printf,idl_out,';  '+line
	    REPEAT BEGIN
	    	READF, IN, line
		line = STRTRIM(line(0),2)
		cmntchk=strmid(line,strlen(line)-2,2)
	    ENDREP UNTIL (cmntchk EQ "*/")
	    printf,idl_out,';  '+line
    	    goto, start1
	ENDIF
	IF cmntchk EQ "//" THEN BEGIN
    	    printf,idl_out,';  '+line
	    goto, start1
	ENDIF
	IF cmntchk EQ "#i" or cmntchk EQ "#e" THEN BEGIN
    	    printf,idl_out,';  '+line
	    goto, start1
	ENDIF
	IF line EQ '' THEN $
	goto, start1
    	uwords = STR_SEP2(line)	;** BREAK UP LINE INTO WORDS
    	words = STRLOWCASE(uwords)
	;help,line
    	return, words
    END
    
FUNCTION write_global_defn, lcwords
COMMON cpp_common, idl_out

    nw = n_elements(lcwords)
    IF (lcwords[nw-1] EQ 'char') or (lcwords[nw-1] EQ 'short') or (lcwords[nw-1] EQ 'int') THEN BEGIN
    	IF (lcwords[nw-1] EQ 'char') THEN type="B" 
    	IF (lcwords[nw-1] EQ 'short') THEN type="S"
    	IF (lcwords[nw-1] EQ 'int') THEN type="L"
    	IF (lcwords[nw-2] EQ 'unsigned') THEN type="U"+type
    	printf,idl_out,lcwords[1]," = 0",type
    ENDIF ELSE $
    	printf,idl_out,lcwords[1]," = ",lcwords[2]
    return,1
    END
    
FUNCTION write_struct_defn, lcwords
COMMON cpp_common, idl_out
    
    words=line2words()	; opening bracket must always be by itself
    words=line2words()	; first member of structure
    types=words[0]
    names=words[1]
    semicolon=strpos(names,';')
    if semicolon GE 0 THEN names=strmid(names,0,semicolon)
    words=line2words()	; 2nd member of structure
    WHILE strmid(words[0],0,1) NE '}' DO begin
	types=[types,words[0]]
    	name=words[1]
	; remove semicolon from name
    	semicolon=strpos(name,';')
    	if semicolon GE 0 THEN name=strmid(name,0,semicolon)
	names=[names,name]
    	words=line2words()
    ENDWHILE
    name=arr2str(words,'')
    semicolon=strpos(name,';')	;  structure name must be on same line as closing bracket
    structname=strmid(name,1,semicolon-1)
    nel=n_elements(names)
    ; write structure definition
    printf,idl_out, structname,' = { ', structname,',$'
    FOR i=0,nel-2 DO BEGIN
	name=names[i]
    	; check for array
	isarr=strpos(name,'[')
	IF isarr GE 0 THEN BEGIN
	    narr = strmid(name,isarr+1,strpos(name,']')-isarr-1)
	    printf,idl_out,'          ',strmid(name,0,isarr),':	replicate(',types[i],',',narr,'),$'
	ENDIF ELSE $
    	printf,idl_out,'          ', names[i],':	',types[i],',$'
    ENDFOR
    ; last element
    name=names[nel-1]
    	; check for array
    isarr=strpos(name,'[')
    IF isarr GE 0 THEN BEGIN
    	narr = strmid(name,isarr+1,strpos(name,']')-isarr-1)
    	printf,idl_out,'          ',strmid(name,0,isarr-1),':	replicate(',types[nel-1],',',narr,') }'
    ENDIF ELSE $
    printf,idl_out,'          ', names[i],':	',types[nel-1],' }'
   return,1
    END
    
FUNCTION write_enum_defn, lcwords
; array of value definitions
; Don't know how this will be used yet, not used for header structure definition
COMMON cpp_common, idl_out

    words=line2words()	; opening bracket must always be by itself
    words=line2words()	; first member of array (no comma on line)
    types=words[0]
    names=words[1]
    words=line2words()	; 2nd member of structure
    WHILE strmid(words[0],0,1) NE '}' DO begin
	types=[types,words[0]]
    	name=words[1]
	names=[names,name]
    	words=line2words()
    ENDWHILE
    name=arr2str(words,'')
    semicolon=strpos(name,';')	;  structure name must be on same line as closing bracket
    codesname=strmid(name,1,semicolon-1)
    nel=n_elements(names)
    ; write array defn
    ; ....
    return,1
    END

PRO cpp2idlstruct, def_file, table_name

COMMON cpp_common, idl_out, in

   whole_name = SPEC_DIR(def_file)
   BREAK_FILE, whole_name, junk1, dir, filnam, ext, junk2, junk3
   out_file_idl = table_name + '_struct.inc'
   ;out_file_c   = filnam + '_struct.h'
   PRINT, '%%DEF2STRUCT: Creating output file: ', out_file_idl

      OPENW, IDL_OUT, out_file_idl, /GET_LUN
      OPENR, IN, def_file, /GET_LUN
  
   today = SYSTIME()
   PRINTF, IDL_OUT, ';*  DB Table IDL structure definition created by CPP2IDLSTRUCT.PRO'
   PRINTF, IDL_OUT, ';*  from ' + whole_name + ' on ' + today
   printf, IDL_OUT, '; $Id: cpp2idlstruct.pro,v 1.3 2005/05/19 19:08:42 nathan Exp $'
   PRINTF, IDL_OUT

    printf,idl_out,'char   = 0UB '
    printf,idl_out,'double = 0d'

   firstcol = 1
   firsttab = 1
   in_desc = 0
   desc = '' & auth = '' & date = ''
   WHILE NOT(EOF(IN)) DO BEGIN
    	words=line2words()
    	type = words(0)

	IF (type EQ 'typedef') THEN type=words[0]+words[1]
        print,type
    	CASE (type) OF
    	    '#define'	    	: junk=write_global_defn(words)
    	    'typedefstruct' 	: junk=write_struct_defn(words)
	    'typedefenum'   	: junk=write_enum_defn(words)
	    'struct'	    	: junk=write_struct_defn(words)
	    'eof' : BEGIN
	    	    print,'EOF encountered'
		    break
		    END
        ELSE: print,'Ignoring ',words
    	ENDCASE
   ENDWHILE
   
   CLOSE, IDL_OUT & FREE_LUN, IDL_OUT
   CLOSE, IN & FREE_LUN, IN

END
