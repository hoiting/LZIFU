;+
; Project     : HESSI
;
; Name        : STR_MATCH
;
; Purpose     : match patterns in a string 
;               (not to be confused with RSI's intrinsic and better STRMATCH)
;
; Category    : string utility
;                   
; Inputs      : SOURCE = source string
;               PATT = pattern to match (e.g. 'fits')
;               (can be vector, or scalar string delimited by comma)
;
; Outputs     : Match results
;
; Keywords    : CASE_SENS: set for case sensitive match (def = no case)
;               BOOL_AND: set for boolean AND match (def = OR)
;               COUNT = # of matched
;
; History     : 4-Apr-2000,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function str_match,source,patt,count=count,$
          case_sens=case_sens,bool_and=bool_and,found=found

found=-1 & count=0
sz=size(source)
if sz(n_elements(sz)-2) ne 7 then return,''
sz=size(patt)
if sz(n_elements(sz)-2) ne 7 then return,source

count=n_elements(source)
if n_elements(patt) eq 1 then $
 patterns=str2arr(patt,delim=',') else patterns=patt
patterns=trim2(patterns)

no_case=(1-keyword_set(case_sens))
if no_case then patterns=strlowcase(patterns)

;-- remove blanks or single wilds

keep=where((patterns ne '') and (patterns ne '*'),npatt)
if npatt eq 0 then begin
 found=lindgen(n_elements(source))
 return,source
endif

patterns=patterns(keep)
                                            
;-- Search for individual cases
;-- Create a bytarr in which to store 0/1 if match is found for
;-- each pattern

if no_case then tsource=strlowcase(source) else tsource=source
patterns=str_replace(patterns,'*','')

pos=bytarr(count,npatt)

for i=0,npatt-1 do pos(i*count)=strpos(tsource,patterns(i)) gt -1

;-- Sum each row of the bytarr. 
;   If a boolean AND, then we need 1's in every
;   row. Hence the sum must equal the number of patterns.
;   If a boolean OR, then we need at least 1 in each row.

mpos=total(transpose(pos),1)

if keyword_set(bool_and) then found=where(mpos eq npatt,count) else $
 found=where(mpos ne 0,count)

results=''
if count gt 0 then results=reform(source(found))
if count eq 1 then begin
 results=results(0) & found=found(0)
endif

return,results
          
end

