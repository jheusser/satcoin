# Satcoin

This is code and CNF files for the [bitcoin mining using SAT solver article](http://jheusser.github.io/2013/02/03/satcoin.html).


## Usage

The C file `satcoin.c` can be run in two modes. Either it can be compiled and executed with a compiler such as GCC, or it can be run using the bounded model checker [CBMC](http://www.cprover.org/cbmc/). The model checker can be used to check the satisfiability of the C code or to generate DIMACS files as input to other SAT solvers.

### Compilation mode

The compilation can be used to verify that the hash calculation is actually performed correctly. By default the input to the program is the [Genesis block](https://en.bitcoin.it/wiki/Genesis_block), the output is the hash of the Genesis block as calculated by the program:

```
$ gcc satcoin.c -o satcoin
$ ./satcoin
00-00-00-00-00-19-d6-68-9c-08-5a-e1-65-83-1e-93-4f-f7-63-ae-46-a2-a6-c1-72-b3-f1-b6-0a-8c-e2-6f-
```
The nonce of the Genesis block is 497822588 and the hash is 

```
000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
```


### Verification mode

In verification mode the nonce of the input block is overwritten with a non-deterministic value around line 109, then the range of the nonce is restricted with the CBMC-specific directive `__CPROVER_assume`.

The range of this assertion determines the difficulty of the CNF file. If the range _includes_ the actual valid nonce of this block then the instance will be satisfiable, if it _excludes_ the value then it will be unsatisfiable.

By default the range of the nonce is between 0 and 10, thus it will be unsatisfiable.

An unsatisfiable instance means there is no nonce that will satisfy the mining criteria.

```
$ cbmc -DCBMC satcoin.c
CBMC version 5.8 64-bit x86_64 macos
Parsing satcoin.c
Converting
Type-checking satcoin
file satcoin.c line 109 function verifyhash: function `nondet_uint' is not declared
file satcoin.c line 163 function verifyhash: function `assert' is not declared
Generating GOTO Program
Adding CPROVER library (x86_64)
Removal of function pointers and virtual functions
Partial Inlining
Generic Property Instrumentation
Starting Bounded Model Checking
....
Solving with MiniSAT 2.2.1 with simplifier
134717 variables, 648661 clauses
SAT checker: instance is UNSATISFIABLE
Runtime decision procedure: 0.661s

** Results:
[verifyhash.assertion.1] assertion flag == 1: SUCCESS

** 0 of 1 failed (1 iteration)
VERIFICATION SUCCESSFUL
```


