#!/bin/bash
# Norbert Manthey, 2018
#
# Create a simple CNF from the satcoin.c file, with SAT/UNSAT and a range of nonces to consider
# All other parameters are forwarded to the CBMC call.
#
# Example call:
# ./create-cnf.sh satcoin-genesis-SAT-1.cnf SAT 1
# ./create-cnf.sh satcoin-genesis-UNSAT-1.cnf UNSAT 1

# input parameter
OUTPUTFILE="$1"
FORMULASTATUS="$2"
RANGE="$3"
shift 3

# check for availability
for tool in cbmc goto-cc
do
	if ! command -v $tool &> /dev/null
	then
		echo "did not find tool $tool, abort"
	fi
done

# temporary file for operation
trap 'rm -rf $TMPDIR' EXIT
TMPDIR=$(mktemp -d)
BINARY=$TMPDIR/satcoin.binary
PLAINOUTPUT=$TMPDIR/satcoin.output.txt
FORMULA=$TMPDIR/satcoin.cnf

# compile the code with the parameters that have been requested
goto-cc satcoin.c -DCBMC -o "$BINARY" -D"$FORMULASTATUS"CNF="$RANGE" 1>&2

# generate CNF from input
cbmc "$BINARY" --dimacs "$@" > "$PLAINOUTPUT"

# print header into formula
echo "c satcoin formula $FORMULASTATUS with nonce range $RANGE" > "$FORMULA"
echo "c converted with cbmc $(cbmc --version) and goto-cc $(goto-cc -dumpversion)" >> "$FORMULA"
echo "c conversion call: $*" >> "$FORMULA"
echo "c" >> "$FORMULA"

# cut CNF from output
cat "$PLAINOUTPUT" | grep -v "^c" | sed -n  '/p cnf /,$p' &>> "$FORMULA"

# move formula
mv "$FORMULA" "$OUTPUTFILE"
