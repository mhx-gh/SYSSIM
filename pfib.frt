(*
 * LANGUAGE    : ANS Forth with extensions
 * PROJECT     : Forth Environments
 * DESCRIPTION : Parallel Fibonacci benchmark
 * CATEGORY    : Benchmark
 * AUTHOR      : Marcel Hendrix 
 * LAST CHANGE : Thursday, May 09, 2013, 22:45, Marcel Hendrix 
 * LAST CHANGE : July 26, 2012, Marcel Hendrix 
 *)


	NEEDS -miscutil
	NEEDS -threads

	REVISION -pfib "--- Matrix mult test    Version 1.00 ---"

	PRIVATES

DOC
(*
	Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz 
	Type:0 Family:6 Model:10 Stepping:7 
	L2 Cache Size : 256 KB, Line size : 64 bytes. Associativity : $06
	FORTH> bench      
	\ serial FIB(47)          : 4807526976 4.458 seconds elapsed.
	\ parallel FIB(47) (0)    : 4807526976 0.651 seconds elapsed.
	\ parallel FIB(47) (1)    : 4807526976 0.402 seconds elapsed.
	\ parallel FIB(47) (1ab)  : 4807526976 0.045 seconds elapsed.
	\ parallel FIB(47) (abcd) : 4807526976 0.005 seconds elapsed.
	\ parallel FIB(47) (2)    : 4807526976 0.650 seconds elapsed.
	\ linear   FIB(47)        : 4807526975 0.000 seconds elapsed. ok

	\ FORTH> bench ( i7-920 @ 2.66 GHz )
	\ serial FIB(47)          : 4807526976 6.707 seconds elapsed.
	\ parallel FIB(47) (0)    : 4807526976 1.012 seconds elapsed.
	\ parallel FIB(47) (1)    : 4807526976 0.620 seconds elapsed.
	\ parallel FIB(47) (1ab)  : 4807526976 0.057 seconds elapsed.
	\ parallel FIB(47) (abcd) : 4807526976 0.007 seconds elapsed.
	\ parallel FIB(47) (2)    : 4807526976 1.021 seconds elapsed.
	\ linear   FIB(47)        : 4807526975 0.000 seconds elapsed. ok
*)
ENDDOC

: fib ( n1 -- n2 )
    DUP 2 < IF
	DROP 1
    ELSE
	DUP  1- RECURSE
	SWAP 2- RECURSE
	+
    ENDIF ; 

\ ... f5          f4       f3       f2        f1             F0
\ ... (f6+f7)  (f5+f6)  (f5+f4)  (f4+f3)   (f3+f2)       f2+2f3+f4
\ ...                            (2f4+f5)  (f3+2f4+f5)   f3+4f4+2f5
\ ...                            (3f5+2f6) (3f4+2f5)     8f5+5f6

CREATE table PRIVATE 1 , 1 , 2 , 3 , 5 , 8 ,
: fib6 ( u -- u2 ) table []CELL @ ; PRIVATE

: sfib ( n1 -- n2 )
	DUP  6 < IF  ( n) fib6 EXIT  ENDIF
	DUP  5 - fib 8 * 
	SWAP 6 - fib 5 * + ;

: >result ( addr u -- ) SWAP LOCKED+! DROP ; PRIVATE

: pfib0 ( n1 -- n2 )
	0 LOCAL fibs
	DUP 6 < IF  fib6 EXIT  ENDIF
	( n) 'OF fibs SWAP
	PAR
	  STARTP  4 - sfib 3 * >result  ENDP
	  STARTP  5 - sfib 5 * >result  ENDP
	  STARTP  6 - sfib 2*  >result  ENDP
	ENDPAR 
	2DROP fibs ;

: pfib1 ( n1 -- n2 )
	0 LOCAL fibs
	DUP 6 < IF  fib6 EXIT  ENDIF
	( n) 'OF fibs SWAP
	PAR
	  STARTP  5 - sfib 8 * >result  ENDP
	  STARTP  6 - sfib 5 * >result  ENDP
	ENDPAR 
	2DROP fibs ;

: pfib_ab ( n1 -- n2 )
	0 LOCAL fibs
	DUP 6 < IF  fib6 EXIT  ENDIF
	( n) 'OF fibs SWAP
	PAR
	  STARTP  5 - pfib1 8 * >result  ENDP
	  STARTP  6 - pfib1 5 * >result  ENDP
	ENDPAR
	2DROP fibs ;

: pfib_abcd ( n1 -- n2 )
	0 LOCAL fibs
	DUP 6 < IF  fib6 EXIT  ENDIF
	( n) 'OF fibs SWAP
	PAR
	  STARTP  5 - pfib_ab 8 * >result  ENDP
	  STARTP  6 - pfib_ab 5 * >result  ENDP
	ENDPAR
	2DROP fibs ;

: pfib2 ( n1 -- n2 )
	0 LOCAL fibs
	DUP 6 < IF  fib6 EXIT  ENDIF
	( n) 'OF fibs SWAP
	PAR
	  STARTP  DUP  5 - sfib 5 * 
	          SWAP 6 - sfib 2* + >result  ENDP
	  STARTP       4 - sfib 3 *  >result  ENDP
	ENDPAR
	2DROP fibs ;

5e FSQRT FDUP 1/F FCONSTANT /sqrt5 PRIVATE
1e F+ F2/ FLN     FCONSTANT gbase  PRIVATE	

: fibL ( n -- ) ( F: -- f )
  DUP S>F gbase F* FDUP FEXP FSWAP FNEGATE FEXP
  1 AND IF F+ ELSE F- THEN  /sqrt5 F* ;

: bench	CR ." \ serial   FIB(47)        : " TIMER-RESET #47 sfib      U. .ELAPSED 
	CR ." \ parallel FIB(47) (0)    : " TIMER-RESET #47 pfib0     U. .ELAPSED  
	CR ." \ parallel FIB(47) (1)    : " TIMER-RESET #47 pfib1     U. .ELAPSED  
	CR ." \ parallel FIB(47) (1ab)  : " TIMER-RESET #47 pfib_ab   U. .ELAPSED  
	CR ." \ parallel FIB(47) (abcd) : " TIMER-RESET #47 pfib_abcd U. .ELAPSED  
	CR ." \ parallel FIB(47) (2)    : " TIMER-RESET #47 pfib2     U. .ELAPSED 
	CR ." \ linear   FIB(47)        : " TIMER-RESET #48  fibL F>S U. .ELAPSED ; 

:ABOUT	CR ." Try: BENCH " ;

NESTING @ 1 = [IF] .ABOUT -pfib CR [THEN] 

		DEPRIVE

                              (* End of Source *)