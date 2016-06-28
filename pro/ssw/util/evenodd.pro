FUNCTION evenodd,num
;+
; $Id: evenodd.pro,v 1.1 2006/04/11 15:55:18 antunes Exp $
;
; Project   : developer area for STEREO SECCHI
;                   
; Name      : evenodd.pro
;               
; Purpose   : returns 0 if input is even, 1 if odd
;               
; Explanation: useful for figuring out rounding directions or interleaves
;               
; Use       : IDL> answer=evenodd(intergernumber)
;    
; Inputs    : number, ideally an integer
;               
; Outputs   : 0 or 1, representing even or odd
;
; Keywords  : none
;
; Calls from LASCO : none 
;
; Common    : none 
;               
; Restrictions: none
;               
; Side effects: none
;               
; Category    : Mathematics
;               
; Prev. Hist. : None.
;
; Written     : Sandy Antunes, NRL, Nov-Dec 2005
;               
; $Log: evenodd.pro,v $
; Revision 1.1  2006/04/11 15:55:18  antunes
; Massive re-org of cvs 'dev' preparatory to moving into solarsoft.
;
; Revision 1.2  2005/12/27 17:48:23  antunes
; Commented half of the routines using SSW style.  Also added a new
; axes test case 'arrowcube'.
; Checked in the Tomography/old/mikic_img.pro routine here because it
; is a dependency for the general image-prep routine 'get_timage.pro'
;
;-            
; simple function, returns 0 if a number is even, 1 if it is odd
; if not given an integer, rounds it and lets you know if rounded
; number is even or odd.  Zero returns as 'even'
  fnum=round(num)
  if (2*(fnum/2) eq fnum) then begin
      return,0
  end else begin
      return,1
  end
  
END
