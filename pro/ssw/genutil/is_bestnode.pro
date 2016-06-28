function is_bestnode, nodelist,  remove=remove, loud=loud, goodorder=goodorder, $
	nprocess=nprocess,  cpuload=cpuload,  memload=memload, defnodes=defnodes
;+
;   Name: is_bestnode
;
;   Purpose: quick and dirty search for 'best' node in nodelist
;            (best nodes are 'alive' and lowest CPU/Memory load or process count)
;
;   Input Parameters:
;      nodelist - string array of nodenames to check
;
;   Keyword Parameters:
;      nprocess    - if set, use non-root process count [default]
;      cpuload     - if set, use minimum cpuload        [not yet implemented]
;      memload     - if set, use minimum memory load    [not yet implemented]
;      remove      - if set, remove the 'best' from the nodelist
; 		     (used for succesive calls from a given program to spread 
;		     the load around)
;      defnodes    - if set, use nodelist defined by env $SITE_BATCHNODES
;      goodorder   - (output) - all members of nodelist in order of 'bestness'
;				(best first, worst last)
;   Output:
;      function returns the 'best' node name (or local node if it is best)
;
;   Calling Sequence:
;      best=is_bestnode(nodelist [,/nprocess, /cpuload, /memload, $
;		 	           goodorder=goodorder , /defnodes]
;   Calling Examples:
;      rsh,is_bestnode(['flare13','flare7','isass1']), rshcommand
;         [checks 3 node plus local node, and calls 'rsh' with the best]
;
;      best=is_bestnode(/defnodes , goodorder=goodorder)
;         [uses nodelist defined by $SITE_BATCHNODES; goodorder (output) 
;         [contains the nodelist sorted by decresing 'bestness'; ie, best node
;	  [first, worst node last]
;
;   History:
;      26-Sep-1994 (SLF) - written to select best host for background tasks
;      27-Sep-1994 (SLF) - dont allow zero processes (Problem TBD)
;      29-sep-1994 (SLF) - fixed problem where rsh to local node resulted in
;			   "Cant make Pipe" (use spawn instead of rsh for local)
;      30-sep-1994 (SLF) - added GOODORDER output keyword
;
;   Category:
;      system, distributed processing, general utility
;
;   Restrictions:
;      Since this is based on a 'ps' snapshot, no written guarantees...
;      only non-root process count for now
;-
case 1 of 
   keyword_set(memload): mesasge,/info,"not implemented yet, using process count"
   keyword_set(cpuload): mesasge,/info,"not implemented yet, using process count"
   else:
endcase

best=get_host(/short)			  ; assume failure (no best node, so use local)

if keyword_set(defnodes) and not keyword_set(nodelist) then $
	nodelist=str2arr(get_logenv('SITE_BATCHNODES'))

if not data_chk(nodelist,/string) then begin
   message,/info,"No nodelist, so best is local node: " + best
endif else begin   
   cnodes=where(nodelist ne '',vcount)
   case vcount of 
     0:
      else: begin
         bnodes=[nodelist(cnodes),get_host(/short)]	; add local node to list
         for i=0,vcount-1 do $				; dont have to check local for alivness
            if not is_alive(bnodes(i)) then $ 		; remove dead nodes
		bnodes=bnodes(rem_elem(bnodes, bnodes(i)))
         ; now we have list of alive nodes
         if n_elements(bnodes) eq 1 then best=bnodes(0) else begin
            pidcnt=intarr(n_elements(bnodes))
            pscmd='ps -aux'
;           use spawn instead of rsh.pro for local node
            for i=0,n_elements(bnodes)-1 do begin
               if i eq n_elements(bnodes) - 1 then spawn,pscmd,psout else $
               rsh,bnodes(i) ,pscmd, psout
               noroot=where(strpos(strtrim(psout,2),'root') ne 0 and strlen(psout) ge 55,pscnt)
               pidcnt(i)=pscnt                           
               message,/info,'Number of non-root processes on ' + bnodes(i) + ': ' + strtrim(pscnt)
               if keyword_set(loud) then prstr, psout(noroot)
            endfor
            bad=where(pidcnt eq 0,bcnt)
;	    *** temp fix - sometimes reporting zero ***
;           partially 'understood' now (cant make pipe error)
            if bcnt gt 0 then begin
	       message,/info,$
		  "Problem with pid count for: " + arr2str(bnodes(bad))
               message,/info,"Ignoring..."
	       file_append,'$ys/site/logs/badpidcnt.dat',psout
               pidcnt(bad) = max(pidcnt) + 1
            endif
	    best=(bnodes(where(pidcnt eq min(pidcnt))))(0)
            goodorder=bnodes(sort(pidcnt))		; full list in order
         endelse               
      endcase
   endcase
endelse


if keyword_set(remove) then begin
   remnode=rem_elem(nodelist,best,rcnt)	; remove this from list
   if rcnt gt 0 then nodelist=nodelist(remnode)
endif

return, best(0)				; scaler
end
