(*
 * LANGUAGE    : ANS Forth with extensions
 * PROJECT     : Forth Environments
 * DESCRIPTION : Parallel Benchmark 
 * CATEGORY    : Example 
 * AUTHOR      : Marcel Hendrix 
 * LAST CHANGE : May 6, 2013, Marcel Hendrix 
 *)



	NEEDS -miscutil
	NEEDS -threads

	REVISION -psieve "--- Parallel Sieve      Version 0.04 ---"

	PRIVATES

DOC
(*

	FORTH> #10000000 TO bsize #1000 TO #redo sieve psieve
	Sieve size = 10,000,000, 1000 iterations : 80.602 seconds elapsed. ( 664579 primes found )
	Sieve size = 10,000,000, 1000 iterations : 21.343 seconds elapsed. ( 664579 primes found )  ok
	FORTH> 80.602e 21.343e f/ f. 3.776508  ok

	FORTH> #10000000 TO bsize #1000 TO #redo  ok
	FORTH> sieve psieve ( using GCD )
	Sieve size = 10,000,000, 1000 iterations : 169.708 seconds elapsed. ( 664579 primes found )  ok
	Sieve size = 10,000,000, 1000 iterations : 39.777 seconds elapsed. ( 664579 primes found )  ok

	Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz 
	Type:0 Family:6 Model:10 Stepping:7 
	L2 Cache Size : 256 KB, Line size : 64 bytes. Associativity : $06
	FORTH> sieve psieve 
	\ Sieve size = 10,000,000, 1000 iterations : 45.233 seconds elapsed. ( 664579 primes found ) 
	\ Sieve size = 10,000,000, 1000 iterations : 13.150 seconds elapsed. ( 664579 primes found )  ok
*)
ENDDOC

: .PRIMES ( addr u start #primes -- )
	1- 1 LOCALS| counter #primes start size prime? |
	CR  start 2 <= IF  2 DEC.  3 TO start  ENDIF
	start 1 AND 0= IF  1 +TO start  ENDIF \ must be odd
	size 0 ?DO  prime? I + C@ 
			IF  counter  C/L 8 - 6 / MOD 0= IF  CR  ENDIF 
			    I 2* start + DEC.  -1 +TO #primes  1 +TO counter 
		     ENDIF  
		    #primes 0< ?LEAVE	
	      LOOP ; PRIVATE

: SQR ( u -- u*u ) DUP * ; PRIVATE
: lowprim? ( u prim -- bool ) 2DUP SQR <= IF  2DROP FALSE EXIT  ENDIF  MOD 0= ; PRIVATE

-- process only odd numbers of a specified block
: SIEVE-ONE-BLOCK ( start end -- #found )
	3 LOCALS| ix end start |
	end start - 1+ 2/       LOCAL size 
	size ALLOCATE ?ALLOCATE LOCAL prime?
		prime? size 1 FILL
		ix >S
		BEGIN  	
			S    3 lowprim?		S   5 lowprim? OR
			S    7 lowprim? OR	S #11 lowprim? OR
			S  #13 lowprim? OR 	S #17 lowprim? OR
			S  #19 lowprim? OR 	S #23 lowprim? OR  
			0= IF
				start S + 1-  S / S * ( minJ)
				S SQR MAX
				DUP 1 AND 0= IF  S +   ENDIF  ( minJ)	\ start value must be odd
				end 1+ SWAP 
				2DUP > IF  DO  I start - 2/ prime? + C0!  S 2* +LOOP  
				     ELSE  2DROP 
				    ENDIF
			ENDIF
			S SQR end <= 
		WHILE  	2 S+!
		REPEAT  -S
		0  size 0 ?DO  prime? I + C@ +  LOOP ( cnt)
		start 2 <= 1 AND + ( cnt)
	prime? FREE ?ALLOCATE ;	
	
: SIEVE-BLOCKS ( last slice -- #found )
	LOCALS| slice last |
	0  last 1+ 2 ?DO  I  I slice + last UMIN  SIEVE-ONE-BLOCK +  slice +LOOP ;

#100      VALUE #redo
#10000000 VALUE bsize ( #8190 2* == Classic Eratosthenes / BYTE benchmark )

: SIEVE ( -- ) 
	TIMER-RESET CR ." \ Sieve size = " bsize U>D ((n,3)) TYPE ." , " #redo DEC. ." iteration" #redo ?S ."  : " 
	0  #redo 0 ?DO   DROP bsize DUP SIEVE-BLOCKS  LOOP  .ELAPSED 
	."  ( " DEC. ." primes found ) " ;

-- parallel implementation

VARIABLE #primes PRIVATE  : res-update ( u -- ) #primes LOCKED+! DROP ; PRIVATE

-- There are 8 threads because the primes are not uniformly distributed over the sieve 
-- and some threads stopped (much) earlier than others. With 8 threads I get 90% CPU on
-- an i7 920 @2.67 Ghz.
: PSIEVE ( -- ) 
	TIMER-RESET CR ." \ Sieve size = " bsize U>D ((n,3)) TYPE ." , " #redo DEC. ." iteration" #redo ?S ."  : " 
	#redo 0 ?DO   
			#primes OFF  
			PAR
			  STARTP          2        bsize   8  /  SIEVE-ONE-BLOCK  res-update  ENDP
			  STARTP  bsize   8  / 1+  bsize 2 8 */  SIEVE-ONE-BLOCK  res-update  ENDP
			  STARTP  bsize 2 8 */ 1+  bsize 3 8 */  SIEVE-ONE-BLOCK  res-update  ENDP
			  STARTP  bsize 3 8 */ 1+  bsize 4 8 */  SIEVE-ONE-BLOCK  res-update  ENDP
			  STARTP  bsize 4 8 */ 1+  bsize 5 8 */  SIEVE-ONE-BLOCK  res-update  ENDP
			  STARTP  bsize 5 8 */ 1+  bsize 6 8 */  SIEVE-ONE-BLOCK  res-update  ENDP
			  STARTP  bsize 6 8 */ 1+  bsize 7 8 */  SIEVE-ONE-BLOCK  res-update  ENDP
			  STARTP  bsize 7 8 */ 1+  bsize         SIEVE-ONE-BLOCK  res-update  ENDP
			ENDPAR
	       LOOP  
	.ELAPSED ."  ( " #primes @ DEC. ." primes found ) " ;

:ABOUT	CR ." Try: SIEVE-ONE-BLOCK ( start end -- #found ) "
	CR ."      SIEVE-BLOCKS ( last slice -- #found ) " 
	CR ."      bsize   -- VALUE, for benchmarks, now " bsize DEC.
	CR ."      #redo   -- VALUE, benchmark loops, now " #redo DEC.
	CR ."      SIEVE   -- serial benchmark" 
	CR ."      PSIEVE  -- parallel benchmark" ;

		
NESTING @ 1 = [IF] .ABOUT -psieve CR [THEN]

		DEPRIVE

                              (* End of Source *)