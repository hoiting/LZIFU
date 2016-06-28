function uniqo, inarr, sinarr, first=first, last=last
;
;+
;   Name: uniqo
;
;   Purpose: return subscripts of uniq elements and maintain original order
;
;   Input Parameters:
;      inarr - array to search (does not have to be in sorted order)
;      
;   Optional Parameters:
;      sinarr - DUMMY, not used - (maintain interface compatible with userlib
;		uniq.pro)
;   
;   Keyword Parameters:
;      last  - NOT YET IMPLEMENTED, switch, if set, subscript of last 
;	       occurence if multiples
;
;   Calling Examples:
;      uss=uniqo(array)		; return subscripts of uniq elements in
;				; original order in variable uss
;
;   History:
;      12-Apr-1993 (SLF) - to preserve order when uniqifying string array's
;			   (idl sorurce code and data path arrays)
;			   (userlib V. supplied with IDL seems to ignore order
;
;   Restrictions:
;      last - keyword not yet implemented - fastest for arrays with many
;	      repeated elements
;-
arrmap=0					;
case n_elements(inarr) of
   0: message,/info,'No Input Array!'		;null input
   1: arrmap=1					;scaler init
   else: begin					;non-scaler 
      arr=inarr
      arrmap=intarr(n_elements(arr)) + 1	;all 1's for starters
      pnt=0l
      repeat begin
         check=where(arr(pnt+1:*) eq arr(pnt),count)	;look for duplicates
         if count gt 0 then arrmap(check+1+pnt) =  0    ;map flags for dupes
         next=where(arrmap(pnt+1:*),count) 	        ;'surviving' indices
         pnt=next(0) +1 + pnt				;next starting point
      endrep until count eq 0 or $			;quit looping
	           pnt eq n_elements(arr)-1
   endcase
endcase

return,where(arrmap)
end
