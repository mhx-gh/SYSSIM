(*
 * LANGUAGE    : ANS Forth
 * PROJECT     : Forth Environments
 * DESCRIPTION : Parallel Bubble Sort with Merge Stage for iForth
 * CATEGORY    : Examples
 * AUTHOR      : Marcel Hendrix
 * LAST CHANGE : Sunday, April 28, 2013, 22:34, Marcel Hendrix 
 * LAST CHANGE : Saturday, April 13, 2013, 11:10, Marcel Hendrix 
 *)


        NEEDS -miscutil
	NEEDS -threads

        REVISION -psorts "--- Parallel BubbleSort Version 1.02 ---"

	PRIVATES

DOC
(*
	Parallel Bubble Sort
	Felician ALECU
	Economic Informatics Department, A.S.E. Bucharest
	alecu.ase.ro/conferences/nat_conf_2005_ro_am.pdf

	The second parallel approach (using MERGE) is my own proposal.

	Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz 
	Type:0 Family:6 Model:10 Stepping:7 
	L2 Cache Size : 256 KB, Line size : 64 bytes. Associativity : $06
	FORTH> bench bench2 
	\ Sorting 262144 numbers at $00007FFB530F8010
	\ serial    : 107.862 seconds elapsed.
	\ parallel  : 48.094 seconds elapsed.
	\ Sorting 262144 numbers at $00007FFB530F8010
	\ serial2   : 55.735 seconds elapsed.
	\ parallel2 : 26.970 seconds elapsed.
	\ parallel4 : 10.467 seconds elapsed. ok

	-- after a reboot, with i7 920 @ 3.3 GHz: ??
	FORTH> bench bench2
	\ Sorting 262144 numbers at $65510050
	\ serial    : 139.111 seconds elapsed.
	\ parallel  : 117.547 seconds elapsed. <<<<< ??
	\ Sorting 262144 numbers at $65510050
	\ serial2   : 70.173 seconds elapsed.
	\ parallel2 : 53.433 seconds elapsed.
	\ parallel4 : 26.639 seconds elapsed.  <<<<< ??
	FORTH> bench bench2
	\ Sorting 131072 numbers at $0B530050
	\ serial    : 34.783 seconds elapsed.
	\ parallel  : 21.515 seconds elapsed.
	\ Sorting 131072 numbers at $0B530050
	\ serial2   : 17.380 seconds elapsed.
	\ parallel2 : 9.087 seconds elapsed.
	\ parallel4 : 3.572 seconds elapsed. ok
	\ FORTH> bench bench2 ( i7 920 @ 2.7 GHz )
	\ Sorting 65536 numbers at $145E0090
	\ serial    : 10.448 seconds elapsed.
	\ parallel  : 7.148 seconds elapsed.
	\ Sorting 65536 numbers at $145E0090
	\ serial2   : 5.203 seconds elapsed.
	\ parallel2 : 2.722 seconds elapsed.
	\ parallel4 : 0.718 seconds elapsed. ok
*)
ENDDOC

$10000 =: n PRIVATE

n     CELLS ALLOCMEM-BUFFER array0 PRIVATE
n 2/  CELLS ALLOCMEM-BUFFER array1 PRIVATE
n 2/  CELLS ALLOCMEM-BUFFER array2 PRIVATE

n      VALUE size    PRIVATE
array0 VALUE array   PRIVATE

: INIT-ARRAY  ( addr sz -- )  0 ?DO  ( RANDOM ) n CHOOSE OVER I CELL[] !  LOOP  DROP ; PRIVATE
: ?SORTED     ( addr sz -- )  1- 0 ?DO  DUP I CELL[] 2@ < ABORT" unsorted"  LOOP  DROP ; PRIVATE
: exchange    ( addr -- ) DUP 2@  ROT D! ; PRIVATE
: exchange?   ( bool1 addr -- bool2 ) DUP 2@ < IF  exchange 1+  ELSE  DROP  ENDIF ; PRIVATE
: SIGNAL:     CREATE 0 ,  DOES> LOCKED+! ; PRIVATE

	SIGNAL: signal1	 PRIVATE
	SIGNAL: signal2  PRIVATE

: clearf ( -- )  ['] signal1 >BODY 0!  ['] signal2 >BODY 0! ; PRIVATE
: job1? ( bool1 up down base -- bool2 ) >S  DO  I 2*     S []CELL  exchange?  LOOP  -S ; PRIVATE
: job2? ( bool1 up down base -- bool2 ) >S  DO  I 2* 1+  S []CELL  exchange?  LOOP  -S ; PRIVATE
: job1  ( bool1 up down base -- ) job1? signal1 DROP ; PRIVATE
: job2  ( bool1 up down base -- ) job2? signal2 DROP ; PRIVATE

: Serial_BubbleSort ( addr u -- )
	LOCALS| size array |
	BEGIN
	  0  
	     size 2/                   0 array job1?
	     size 2/  size 1 AND + 1-  0 array job2?
	  0=
	UNTIL ; 

: Parallel_BubbleSort ( addr u -- )
	TO size TO array 
	BEGIN
	   clearf
		PAR
		  STARTP  0  size 8 /             	        0 array job1  ENDP
		  STARTP  0  size 4 /                    size 8 / array job1  ENDP
		  STARTP  0  size 3 8 */  	         size 4 / array job1  ENDP
		  STARTP  0  size 2/                  size 3 8 */ array job1  ENDP
		ENDPAR
		PAR
		  STARTP  0  size 8 /	  	                0 array job2  ENDP
		  STARTP  0  size 4 /	                 size 8 / array job2  ENDP
		  STARTP  0  size 3 8 */                 size 4 / array job2  ENDP
		  STARTP  0  size 2/ size 1 AND + 1-  size 3 8 */ array job2  ENDP
		ENDPAR	
	   0 signal1 0 signal2 OR 0=
	UNTIL ;

\ FORTH> bench
\ Sorting 262144 numbers at $0B420050
\ serial    : 152.877 seconds elapsed.
\ parallel  : 66.201 seconds elapsed. ok

: BENCH ( -- )
	CR ." \ Sorting " n U. ." numbers at " array0 H.
	CR ." \ serial    : " array0 n INIT-ARRAY  TIMER-RESET array0 n   Serial_BubbleSort .ELAPSED  array0 n ?SORTED
	CR ." \ parallel  : " array0 n INIT-ARRAY  TIMER-RESET array0 n Parallel_BubbleSort .ELAPSED  array0 n ?SORTED ;

-- Merge two sorted lists, save at HERE
: (MERGE) ( al ul ar ur -- start size )
	LOCALS| ur ar ul al | 
	HERE ul ur +
	BEGIN   
	  ur ul OR  
	WHILE	
	  ul 0> ur 0> AND 
	     IF  al @ ar @ 2DUP 
	  	 <= IF  DROP , CELL +TO al 1 -TO ul
		  ELSE  NIP  , CELL +TO ar 1 -TO ur  ENDIF
   	   ELSE  ul IF  al @ , CELL +TO al 1 -TO ul  ELSE 
		 ur IF  ar @ , CELL +TO ar 1 -TO ur 
		 ENDIF ENDIF
	  ENDIF
	REPEAT ; PRIVATE

: MERGE2 ( -- )	
	array0 n 2/  array0 n 2/ CELLS + n 2/  (MERGE) array0  SWAP CELLS  MOVE ; PRIVATE

: MERGE4 ( -- )
	array0 		      n 4 /    array0 n 4 /    CELLS +  n 4 /  (MERGE)  array1  SWAP CELLS  MOVE  
	array0 n 2 / CELLS +  n 4 /    array0 n 3 4 */ CELLS +  n 4 /  (MERGE)  array2  SWAP CELLS  MOVE  
	array1                n 2/     array2                   n 2/   (MERGE)  array0  SWAP CELLS  MOVE ; PRIVATE

\ FORTH> bench2
\ Sorting 262144 numbers at $0B420050
\ serial2   : 76.686 seconds elapsed.
\ parallel2 : 39.811 seconds elapsed.
\ parallel4 : 12.182 seconds elapsed. ok

: s2	CR ." \ serial2   : " 
	TIMER-RESET 
		array0 n INIT-ARRAY
		  array0              n 2/ Serial_BubbleSort 
		  array0 n 2/ CELLS + n 2/ Serial_BubbleSort 
		  MERGE2
		array0 size ?SORTED
	.ELAPSED ;

: p2	CR ." \ parallel2 : " 
	TIMER-RESET 
		array0 n INIT-ARRAY
		  PAR
		    STARTP  array0              n 2/ Serial_BubbleSort  ENDP
		    STARTP  array0 n 2/ CELLS + n 2/ Serial_BubbleSort  ENDP
		  ENDPAR
		  MERGE2
		array0 size ?SORTED
	.ELAPSED ;

: p4	CR ." \ parallel4 : " 
	TIMER-RESET 
		array0 n INIT-ARRAY
		  PAR
		    STARTP  array0                    n 4 / Serial_BubbleSort  ENDP
		    STARTP  array0 n 4 /    CELLS +   n 4 / Serial_BubbleSort  ENDP
		    STARTP  array0 n 2 /    CELLS +   n 4 / Serial_BubbleSort  ENDP
		    STARTP  array0 n 3 4 */ CELLS +   n 4 / Serial_BubbleSort  ENDP
		  ENDPAR
		  MERGE4
		array0 size ?SORTED
	.ELAPSED ;
	
: BENCH2 ( -- )
	CR ." \ Sorting " n U. ." numbers at " array0 H.
	s2 p2 p4 ;

:ABOUT  CR ." *** Parallel Sorting ***"
        CR ." Try: BENCH BENCH2" ;

    NESTING @ 1 = [IF]  .ABOUT -psorts CR  [THEN]

    DEPRIVE

                              (* End of Source *)