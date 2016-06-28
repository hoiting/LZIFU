function getenv_slash,envvar
;+
; $Id: getenv_slash.pro,v 1.1 2006/10/10 15:44:43 nathan Exp $
;
; PROJECT:  STEREO/SECCHI, SOHO/LASCO
;
; NAME:     GETENV_SLASH
;
; PURPOSE:  Calls GETENV to return the environment variable, and then checks to 
;	see if a slash is at the end of the string and appends one if there 
;	isn't.
;
; CATEGORY: REDUCE, operating system, utility, file
;
; CALLING SEQUENCE:
;	Result = GETENV_SLASH (Envvar)
;
; INPUTS:
;	Envvar = String of the environment variable
;
; OUTPUTS:
;	Result = Environment variable with a slash (delimiter)
;
; PROCEDURE:
;	If the environment variable is defined, a slash is appended to the 
;	string returned by GETENV.
;
; EXAMPLE:
;	s = GETENV_SLASH ('LEB_IMG')
;	If $LEB_IMG is defined to be /net/lasco6/data/packets
;	then the result would be:    /net/lasco6/data/packets/
;
; MODIFICATION HISTORY:
;	Written    RA Howard, NRL, 1 Nov 1995
;	Version 1  RAH, Initial Release
;	Version 2  RAH, Use system variable !delimiter
;	 8.16.01, NBR - Check existence of !delimiter using datatype
;	12.17.01, NBR - Use get_delim.pro instead of '/'
;
;       NRL LASCO IDL LIBRARY
;
; $Log: getenv_slash.pro,v $
; Revision 1.1  2006/10/10 15:44:43  nathan
; updated version of LASCO utility
;
; 10/06/06  RCC - Check existence of !delimiter using defsysv
;
;-
;
dir = getenv(envvar)
len=strlen(dir)
DEFSYSV, '!DELIMITER', EXISTS = i  
IF i NE 1 THEN sl=get_delim()  ELSE sl=!delimiter
if (len gt 0) then if (strmid(dir,len-1,1) ne sl) then dir=dir+sl
return,dir
end
