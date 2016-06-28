pro anydata2paper, index, data, _extra=_extra
;+
;   Name: anydata2paper
;
;   Purpose: analyze your data and submit to selected Journal
;
;   Input Parameters:
;      index, data  - any SSW standards
;
;   Keyword Parameters:
;      filling_factor - if not supplied, will derive a number between
;                       10e-4 and 1 which best suppports your theory
;
;      buzzwords - buzzwords to include - if supplied as a switch, will
;                  default to buzzword-du-jour
;
;      bypass_peer_review - obvious (may make this the default...)
;
;      journal - (default='Apj')
;
;      landmark - if set, make this a landmark paper
;
;      error_analysis - if set, include detailed error analysis
;           (by popular demand, default denies any and all sources of error)
;
;      fast - if set, run an order of magnitude faster
;
;  Calling Example:
;
;  IDL> anydata2paper,index,data,journal='Nature',title='How CMEs Work',$
;          filling_factor='best_fudge', equations='NONE', $
;          buzzwords=['sigmoids','helicity','exploding sheared core fields',$
;          'magnetic carpet','dimming'], /bypass_peer_review, /fast
;
;  Side Effects
;     Generated paper will be written to selected journal data base for 
;     publication in next available issue.
;
;  History:
;     Circa 1990  - S.L.Freeland - Written
;     15-Feb-2000 - Pons and Fleischman - add /BYPASS_PEER_REVIEW 
;
;-
box_message,['Sorry, based on a comparison of your claimed C.V. with a',$
            'background check, you are not authorized to use this routine']
return
end
