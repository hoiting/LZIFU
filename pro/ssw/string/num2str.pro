;+
; Project     : SOHO - CDS     
;                   
; Name        : NUM2STR()
;               
; Purpose     : Convert number to unpadded string
;               
; Explanation : 
;	The main and original purpose of this procedure is to convert a number
;	to an unpadded string (i.e. with no blanks around it.)  However, it 
;	has been expanded to be a multi-purpose formatting tool.  You may 
;	specify a length for the output string; the returned string is either 
;	set to that length or padded to be that length.  You may specify 
;	characters to be used in padding and which side to be padded.  Finally,
;	you may also specify a format for the number.  NOTE that the input 
;	"number" need not be a number; it may be a string, or anything.  It is
;	converted to string.
;               
; Use         :  IDL> tmp = NUM2STR(number,[LENGTH=,PADTYPE=,PADCHAR=,FORMAT=])
;               
;	         eg. print,'Used ',num2str(stars),' stars.'  
;                    ==> 'Used 22 stars.'
;	             print,num2str('M81 Star List',length=80,padtype=2)
;	             ==> an 80 character line with 'M81 Star List' centered.
;	             print,'Error: ',num2str(err,format='(f15.2)')
;	             ==> 'Error: 3.24'     or ==> 'Error: 323535.22'
;    
; Inputs      :  NUMBER    This is the input variable to be operated on.  
;                          Traditionally it was a number, but it may be 
;                          any scalar type.
;               
; Opt. Inputs :  None
;               
; Outputs     :  TMP       The formatted string
;               
; Opt. Outputs:  None
;               
; Keywords    :  LENGTH    Specifies the length of the returned string.  
;		           If the output would have been longer, it is 
;                          truncated.  If the output would have been shorter, 
;                          it is padded to the right length.
;
;	         PADTYPE   This KEYWORD specifies the type of padding to be 
;                          used, if any.  0=Padded at End, 1=Padded at front, 
;                          2=Centered (pad front/end) IF not specified, 
;                          PADTYPE=1
;
;                PADCHAR   This KEYWORD specifies the character to be used 
;                          when padding. The default is a space (' ').
;
;                FORMAT    This keyword allows the FORTRAN type formatting 
;                          of the input number (e.g. '(f6.2)')
;
; Calls       :  None
;               
; Restrictions:  None
;               
; Side effects:  None
;               
; Category    :  Util, Numerical, String
;               
; Prev. Hist. :  Original STRN written by Eric W. Deutsch
;
; Written     :  E. W Deutsch
;               
; Modified    :  CDS version C D Pike, RAL, 13-May-93
;
; Version     :  Version 1, 13-May-1993
;-            

function num2str, number, LENGTH = length, PADTYPE = padtype, $
                          PADCHAR = padchar, FORMAT = Format

On_error,2

;
;  if no parameters..
;
if ( N_params() LT 1 ) then begin
    print,'Call: IDL> tmp=num2str(number,[length=,padtype=,padchar=,format=])'
    print,"e.g.: IDL> print,'Executed ',num2str(ret,leng=6,padt=1,padch='0')"+$
                            "' retries.'"
    return,''
endif

;
;  defaults
;
if (N_elements(padtype) eq 0) then padtype=1
if (N_elements(padchar) eq 0) then padchar=' '
if (N_elements(Format) eq 0) then Format=''

;
;  storage
;
padc = byte(padchar)
pad = string(replicate(padc(0),200))


ss=size(number) & PRN=1 & if (ss(1) eq 7) then PRN=0
if ( Format EQ '') then begin
   tmp = strtrim( string(number, PRINT=PRN),2) 
endif else begin
   tmp = strtrim( string( number, FORMAT=Format, PRINT=PRN),2)
endelse
  
if (N_elements(length) eq 0) then length=strlen(tmp)

if (strlen(tmp) gt length) then tmp=strmid(tmp,0,length)

if (strlen(tmp) lt length) and (padtype eq 0) then begin
  tmp = tmp+strmid(pad,0,length-strlen(tmp))
endif

if (strlen(tmp) lt length) and (padtype eq 1) then begin
  tmp = strmid(pad,0,length-strlen(tmp))+tmp
endif

if (strlen(tmp) lt length) and (padtype eq 2) then begin
  padln=length-strlen(tmp) & padfr=padln/2 & padend=padln-padfr
  tmp=strmid(pad,0,padfr)+tmp+strmid(pad,0,padend)
endif

return,tmp


end
