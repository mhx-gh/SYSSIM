[defined] WARNING [IF]   WARNING OFF  [THEN]

CR .TICKER-INFO CR

MARKER -bench
INCLUDE psieve.frt SIEVE PSIEVE
-bench

MARKER -bench
INCLUDE psorts.frt BENCH2 
-bench

MARKER -bench
INCLUDE pmatrix-mult.frt TESTS 
-bench

MARKER -bench
INCLUDE pfib.frt BENCH 
-bench


[defined] WARNING [IF]   WARNING ON  [THEN]

DOC
(*
	Vendor id cpu: GenuineIntel
	Brand string: Intel(R) Core(TM) i7 CPU 920  @ 2.67GHz
	Type:0 Family:6 Model:10 Stepping:5
	Cache description: data L1 cache, 32 KB, 8 ways, 64 byte lines.
	L2 Cache Size : 256 KB, Line size : 64 bytes. Associativity : $06
	Prescott New Instructions (SSE3)

	FORTH> include iforth-make.frt
	Creating --- OS Threads          Version 1.47 ---
	Creating --- Parallel Sieve      Version 0.04 ---
	\ Sieve size = 10,000,000, 100 iterations : 8.009 seconds elapsed. ( 664579 primes found )
	\ Sieve size = 10,000,000, 100 iterations : 2.151 seconds elapsed. ( 664579 primes found )
	Removing --- Parallel Sieve      Version 0.04 ---
	Removing --- OS Threads          Version 1.47 ---
	Creating --- OS Threads          Version 1.47 ---
	Creating --- Parallel BubbleSort Version 1.02 ---
	\ Sorting 65536 numbers at $145E0090
	\ serial2   : 5.184 seconds elapsed.
	\ parallel2 : 2.719 seconds elapsed.
	\ parallel4 : 0.763 seconds elapsed.
	Removing --- Parallel BubbleSort Version 1.02 ---
	Removing --- OS Threads          Version 1.47 ---
	Creating --- OS Threads          Version 1.47 ---
	Creating --- Matrix mult test    Version 1.00 ---
	\ DAXPY mmul using 64 bits floats.
	\ Matrix size = 800x800, performed 32 times
	\ mmul1 (serial   axpy_sse2 1T) :  5.2428718079999999996e+0015 8.090 seconds elapsed.
	\ mmul2 (parallel axpy_sse2 4T) :  5.2428718079999999996e+0015 4.157 seconds elapsed.
	\ mmul3 (parallel axpy_sse2 8T) :  5.2428718079999999996e+0015 2.359 seconds elapsed.
	Removing --- Matrix mult test    Version 1.00 ---
	Removing --- OS Threads          Version 1.47 ---
	Creating --- OS Threads          Version 1.47 ---
	Creating --- Matrix mult test    Version 1.00 ---
	\ serial   FIB(47)        : 4807526976 6.646 seconds elapsed.
	\ parallel FIB(47) (0)    : 4807526976 0.985 seconds elapsed.
	\ parallel FIB(47) (1)    : 4807526976 0.616 seconds elapsed.
	\ parallel FIB(47) (1ab)  : 4807526976 0.056 seconds elapsed.
	\ parallel FIB(47) (abcd) : 4807526976 0.007 seconds elapsed.
	\ parallel FIB(47) (2)    : 4807526976 1.014 seconds elapsed.
	\ linear   FIB(47)        : 4807526975 0.000 seconds elapsed.
	Removing --- Matrix mult test    Version 1.00 ---
	Removing --- OS Threads          Version 1.47 ---  ok
*)
ENDDOC
