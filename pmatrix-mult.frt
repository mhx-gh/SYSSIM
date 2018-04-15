(*
 * LANGUAGE    : ANS Forth with extensions
 * PROJECT     : Forth Environments
 * DESCRIPTION : matrix code compiler
 * CATEGORY    : Benchmark
 * AUTHOR      : Marcel Hendrix 
 * LAST CHANGE : Thursday, May 09, 2013, 22:45, Marcel Hendrix 
 * LAST CHANGE : July 26, 2012, Marcel Hendrix 
 *)



	NEEDS -miscutil
	NEEDS -threads

	REVISION -pmatrix-mult "--- Matrix mult test    Version 1.00 ---"

	PRIVATES

DOC
(*
  Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz 
  Type:0 Family:6 Model:10 Stepping:7 
  L2 Cache Size : 256 KB, Line size : 64 bytes. Associativity : $06
  FORTH> tests 
  \ DAXPY mmul using 64 bits floats.
  \ Matrix size = 800x800, performed 32 times
  \ mmul1 (serial   axpy_sse2 1T) :  5.2428718079999999996e+0015 4.695 seconds elapsed.
  \ mmul2 (parallel axpy_sse2 4T) :  5.2428718079999999996e+0015 2.063 seconds elapsed.
  \ mmul3 (parallel axpy_sse2 8T) :  5.2428718079999999996e+0015 1.769 seconds elapsed. ok
*)
ENDDOC

  #800     =: /rsz  PRIVATE
/rsz DUP * =: /size PRIVATE

CREATE  a1 PRIVATE /size DFLOATS ALLOT
CREATE  a2 PRIVATE /size DFLOATS ALLOT
CREATE  a3 PRIVATE /size DFLOATS ALLOT

: filla   ( -- ) a1 /size 0 DO  I S>F DF!+  LOOP DROP ; PRIVATE 
: fillb   ( -- ) a2 /size 0 DO  1e    DF!+  LOOP DROP ; PRIVATE 
: fillc   ( -- ) a3 /size DFLOATS ERASE ; PRIVATE  

: mmul1 ( F: -- r )
	a3 /size DFLOATS ERASE
	/rsz 0 DO  
		/rsz 0 DO  
			   a1 J /rsz * I + DFLOAT[] DF@  \ A(i,k)
			   a2 I /rsz *     DFLOAT[]      \ B(k,:) 
			   a3 J /rsz *     DFLOAT[] 	 \ C(i,:)
			   /rsz DAXPY_sse2  
		     LOOP 
	     LOOP 
	0e  a3 /size 0 ?DO  DF@+ F+  LOOP DROP ;

0 VALUE jj PRIVATE

: mmul2 ( F: -- r )
	a3 /size DFLOATS ERASE
	/rsz 0 DO  
		   I TO jj
		   PAR
		     STARTP  /rsz 0 DO  a1 jj     /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj     /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 1+  /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 1+  /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 2+  /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 2+  /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 3 + /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 3 + /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP
		   ENDPAR
	  4 +LOOP 
	0e  a3 /size 0 ?DO  DF@+ F+  LOOP DROP ;

: mmul3 ( F: -- r )
	a3 /size DFLOATS ERASE
	/rsz 0 DO  
		   I TO jj
		   PAR
		     STARTP  /rsz 0 DO  a1 jj     /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj     /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 1+  /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 1+  /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 2+  /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 2+  /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 3 + /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 3 + /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP

		     STARTP  /rsz 0 DO  a1 jj 4 + /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 4 + /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 5 + /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 5 + /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 6 + /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 6 + /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP 
		     STARTP  /rsz 0 DO  a1 jj 7 + /rsz * I + DFLOAT[] DF@   a2 I /rsz * DFLOAT[]   a3 jj 7 + /rsz * DFLOAT[]  /rsz DAXPY_sse2   LOOP ENDP
		   ENDPAR
	  8 +LOOP 
	0e  a3 /size 0 ?DO  DF@+ F+  LOOP DROP ;

: TESTS ( u -- )
	#32 LOCAL #mtrys
	CR ." \ DAXPY mmul using 64 bits floats."
	CR ." \ Matrix size = " /rsz 0DEC.R &x EMIT /rsz 0DEC.R ." , performed " #mtrys 0DEC.R ."  times"
	filla fillb fillc
	CR ." \ mmul1 (serial   axpy_sse2 1T) : " TIMER-RESET 0e #mtrys 0 DO  mmul1  F+  LOOP +E. SPACE .ELAPSED  
	CR ." \ mmul2 (parallel axpy_sse2 4T) : " TIMER-RESET 0e #mtrys 0 DO  mmul2  F+  LOOP +E. SPACE .ELAPSED 
	CR ." \ mmul3 (parallel axpy_sse2 8T) : " TIMER-RESET 0e #mtrys 0 DO  mmul3  F+  LOOP +E. SPACE .ELAPSED ;

\ FORTH> tests
\ DAXPY mmul using 64 bits floats.
\ Matrix size = 800x800, performed 32 times
\ mmul1 (serial   axpy_sse2 1T) :  5.2428718079999999996e+0015 8.506 seconds elapsed.
\ mmul2 (parallel axpy_sse2 4T) :  5.2428718079999999996e+0015 4.437 seconds elapsed.
\ mmul3 (parallel axpy_sse2 8T) :  5.2428718079999999996e+0015 2.606 seconds elapsed. ok

NESTING @ 1 =
  [IF]

:ABOUT	CR ." Try: TESTS " ;

		.ABOUT -pmatrix-mult CR
[THEN]

		DEPRIVE

                              (* End of Source *)