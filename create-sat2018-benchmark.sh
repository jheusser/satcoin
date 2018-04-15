#!/bin/bash
# Norbert Manthey, 2018
#
# Create a set of input formulas, with some linear and exponential distribution

# make sure we are in the correct directory
SCRIPTDIR="$(dirname "${BASH_SOURCE[0]}" )"
cd "$SCRIPTDIR"

mkdir -p benchmark

# both SAT and UNSAT
for STATUS in SAT UNSAT
do
	# some linear and exponentially distributed ranges
	for RANGE in $(seq 1 10) 16 32 64 128 256 512 1024 2048 4096 8192
	do
		# create formula, and move the zipped version into the
		# benchmark directory
		FORMULA=satcoin-genesis-$STATUS-$RANGE.cnf
		./create-cnf.sh "$FORMULA" $STATUS $RANGE
		gzip "$FORMULA"
		mv "$FORMULA.gz" benchmark/
	done
done
