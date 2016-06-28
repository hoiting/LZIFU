PRO YESNO,IN
;
;+
;NAME:
;	yesno
;PURPOSE:
;	To determine what the answer to a yes or no question was
;	will take the following:
;
;	-----   YES  -------           -----  NO  -------
;	     
;	        YES                           NO
;		yes                           no
;		Y                             N
;		y                             n
;               1                             0
;                                             <CR>
;INPUT/OUTPUT:
;	in	- The value to be checked
;		Yes will return an integer  1
;		No will return an integer  0
;
;HISTORY:
;	Written by Michael VanSteenberg Update  5/27/81
;-
;****************************************************************
ENT: IF IN EQ ''    THEN IN='NO'
     IF IN EQ 'y'   THEN IN='Y'
     IF IN EQ 'n'   THEN IN='N'
     IF IN EQ 'yes' THEN IN='Y'
     IF IN EQ 'no'  THEN IN='N'
A=BYTE(IN)
S=SIZE(A)
S=S(1)
INN=-999
IF ((A(0) EQ 89) OR (A(0) EQ 49)) OR (A(0) EQ 0) THEN INN=1
IF (A(0) EQ 78) OR (A(0) EQ 48) THEN INN= 0
IF A(0) EQ 50 THEN INN=2
IF S GT 1 THEN BEGIN
   IF (A(0) EQ 83) AND (A(1) EQ 68) THEN INN=2
   IF (A(0) EQ 83) AND (A(1) EQ 84) THEN STOP
END
IF INN EQ -999 THEN BEGIN
    PRINT,'THIS IS NOT A VALID RESPONSE  ',IN,''  ;BELL
    IN=' '
    READ,'WOULD YOU PLEASE ANSWER WITH A VALID RESPONSE ?',IN
    GOTO,ENT
END
IN=INN
RETURN
END
