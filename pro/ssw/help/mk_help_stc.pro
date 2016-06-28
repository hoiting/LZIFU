;---------------------------------------------------------------------------
; Document name: mk_help_stc.pro
; Created by:    Liyun Wang, GSFC/ARC, May 12, 1995
;
; Last Modified: Fri Aug  9 16:14:06 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION mk_help_stc, help_file, sep_char=sep_char
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       MK_HELP_STC()
;
; PURPOSE:
;       To create a help structure to be used in help mode
;
; EXPLANATION:
;       This routine reads in a help file and creates a structure
;       whose tag names are help topics, and whose tag values are
;       string arrays or scalars corresponding to the topics. The help
;       file it reads should be in the same format as that readable by
;       WIDG_HELP. The only restricion is that the string for a help
;       topic can not exceed 15 characters (the rest of characters
;       will be truncated). Also the space between words in a help
;       topic will be converted into the underscore character in the
;       tag names.
;
; CALLING SEQUENCE:
;       Result = mk_help_stc(help_file)
;
; INPUTS:
;       HELP_FILE - The name of a file that contains the help
;                   information to display.  This program searches for a
;                   file with this name first in the current directory,
;                   and then in !PATH, and searches for the name by
;                   itself, and with '.hlp' appended after it.
;
;                   The file consists of a series of topic headers
;                   followed by a text message about that topic.  The
;                   topic headers are differentiated by starting with
;                   the "!" character in the first column (if the
;                   keyword SEP_CHAR not set) or the character
;                   specified via the SEP_CHAR keyword. For example,
;
;                        !Overview
;                        This is the overview for the
;                        topic at hand.
;
;                        !Button1
;                        This is the help explanation
;                        for button 1
;
;                        etc.
;
;                   The program assumes that the first line in the file
;                   (except commentary lines or blank lines) contains
;                   the first topic.  Also, there must be at least one
;                   line between any two topics.  Thus,
;
;                        !Button2
;                        !Button3
;
;                   is not allowed, but
;
;                        !Button2
;
;                        !Button3
;
;                   is allowed.  The last topic in the file must have at
;                   least one non-topic line after it.
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - An anonymous strucuture which has tags named the same as the
;                topic headers in the help file and the value of those tags
;                are the text messages about the topic. A -1 will be
;                returned for syntax error or failure to open the help file.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       SEP_CHAR - Character used to differentiate topic
;                  headers. The default SEP_CHAR is '!'
;
; CALLS:
;       DATATYPE, DELVARX, FIND_WITH_DEF
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       Name of topic header is truncated at 16th character.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Utilities, Help
;
; PREVIOUS HISTORY:
;       Written May 12, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, May 12, 1995
;       Version 2, August 8, 1996, Liyun Wang, NASA/GSFC
;          Used a more efficient way to create structure for OS
;             families other than VMS
;
; VERSION:
;       Version 2, August 8, 1996
;-
;
   ON_ERROR, 2
   IF datatype(help_file) NE 'STR' THEN BEGIN
      MESSAGE, 'Syntax: HELP_STC = MK_HELP_STC(help_file)',/cont
      RETURN, -1
   ENDIF

;---------------------------------------------------------------------------
;  See if SEP_CHAR is passed
;---------------------------------------------------------------------------
   IF datatype(sep_char) NE 'STR' THEN sep_char = '!'
   comment = ';'

;---------------------------------------------------------------------------
;  Open the help file
;---------------------------------------------------------------------------
   file = find_with_def(help_file,!path,'.hlp')
   IF file EQ '' THEN BEGIN
      MESSAGE, 'Unable to open file '+help_file, /cont
      RETURN, -1
   ENDIF

   OPENR, unit, file, /GET_LUN

   line = ''
;---------------------------------------------------------------------------
;  Search for the first topic header
;---------------------------------------------------------------------------
   WHILE (N_ELEMENTS(topic) EQ 0) DO BEGIN
      READF, unit, line
      char = STRMID(line,0,1)
      IF char NE comment AND char EQ sep_char THEN BEGIN
         topic = STRCOMPRESS(STRMID(line,1,STRLEN(line)-1))
         topic = STRMID(repchar(topic,' ','_'),0,15)
      ENDIF
   ENDWHILE

;---------------------------------------------------------------------------
;  Keep reading the file, and collect all the topics and text.
;---------------------------------------------------------------------------
   text = ''
   WHILE NOT EOF(unit) DO BEGIN
      READF, unit, line
      char = STRMID(line, 0, 1)
      IF char NE comment THEN BEGIN
         IF char EQ sep_char THEN BEGIN
            IF N_ELEMENTS(text) GT 1 THEN BEGIN 
               text = text(1:*)
;---------------------------------------------------------------------------
;              Get a new topic; add the content of previous topic to the stc
;---------------------------------------------------------------------------
;               IF KEYWORD_SET(add_tag) THEN BEGIN
                  help_stc = add_tag(help_stc, text, topic)
;                ENDIF ELSE BEGIN
;                   IF N_ELEMENTS(help_stc) EQ 0 THEN BEGIN
;                      help_stc = CREATE_STRUCT(topic, text)
;                   ENDIF ELSE BEGIN
;                      help_stc = CREATE_STRUCT(help_stc, topic, text)
;                   ENDELSE
;                ENDELSE
               topic = STRCOMPRESS(STRMID(line, 1, STRLEN(line)-1))
               topic = STRMID(repchar(topic, ' ', '_'), 0, 15)
            ENDIF 
            text = ''
         END ELSE BEGIN
            text = [text, line]
         ENDELSE
      ENDIF
   ENDWHILE

;---------------------------------------------------------------------------
;  Add the last topic to the stc
;---------------------------------------------------------------------------
   IF N_ELEMENTS(text) GT 1 THEN BEGIN
      text = text(1:*)
      help_stc = CREATE_STRUCT(help_stc, topic, text)
   ENDIF

   CLOSE, unit
   FREE_LUN, unit

   RETURN, help_stc
END

;---------------------------------------------------------------------------
; End of 'mk_help_stc.pro'.
;---------------------------------------------------------------------------
