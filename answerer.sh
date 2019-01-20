#!/bin/bash -eu
[ "${DEBUG:-}" = 1 ] && set -o xtrace

MAX=1000

ans_q1() {
	cd q1
	for i in $(seq -f "%04g" 1 ${MAX}); do
		mkdir -p ${i}dir
		tar xfk $i.tar -C ./${i}dir
		rm $i.tar
	done
	cd - > /dev/null
}

ans_q2() {
	cd q2
	for i in  $(seq -f "%04g" 1 ${MAX}); do
		[ ! -f $i.tar ] && continue;
		mkdir -p ${i}dir
		tar xfk $i.tar -C ./${i}dir &>/dev/null || echo "$i.tar is illegal";
		rm $i.tar
	done
	cd - > /dev/null
}

ans_q3() {
	cd q3
	for i in $(seq -f "%04g" 1 ${MAX}); do
		mkdir -p ${i}dir
		tar xfk $i.tar -C ./${i}dir
		#tar xf $i.tar
		rm $i.tar
	done
	cd - > /dev/null
}

case "${1:-}" in
	q*) ans_${1:-} ;;
	help|h) echo "Usage: $0 q{1..n}" ;;
	all|*)
		for func in $(grep -E "^ans_q" $0|sed -E "s/\(.*//"); do
			$func
		done
		;;
esac
