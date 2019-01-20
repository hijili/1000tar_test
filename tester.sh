#!/bin/bash -eu
[ "${DEBUG:-}" = 1 ] && set -o xtrace

MAX=1000

mk_q1() {
	name=q1; rm -rf $name; mkdir -p $name; cd $name
	echo "$name: 0001.tar ... 1000.tar がある。解凍せよ。"
	echo "    なお、tarには同名のtxtファイルが1つだけ含まれていることが分かっている。"

	for i in $(seq 1 ${MAX}); do
		file=$(printf "%04g" $i).txt
		tarfile=$(printf "%04g" $i).tar
		echo "data $i" > $file
		tar --remove-files -cf $tarfile $file
	done
	cd - >/dev/null
}
assert_q1() {
	name=q1; cd $name
	trap 'echo "$name: たぶんなんか間違ってます"; exit 1' ERR
	for i in $(seq 1 ${MAX}); do
		file=$(printf "%04g" $i).txt
		find . -name $file | xargs grep -q -E "data $i$"
	done
	cd - >/dev/null
	echo "$name: たぶん正解です、たぶん"
}

mk_q2() {
	name=q2; rm -rf $name; mkdir -p $name; cd $name
	echo "$name: 0001.tar ... 1000.tar がある。解凍せよ。同時に、tarでないファイルを特定し削除せよ。"
	echo "    なお、tarには同名のtxtファイルが1つだけ含まれていることが分かっている。"

	for i in $(seq 1 ${MAX}); do
		file=$(printf "%04g" $i).txt
		tarfile=$(printf "%04g" $i).tar
		echo "data $i" > $file
		if [ $(( $i % 3 )) = 0 ] || [ $(( $i % 5 )) = 0 ]; then
			mv $file $tarfile
		else
			tar --remove-files -cf $tarfile $file
		fi
	done
	cd - >/dev/null
}
assert_q2() {
	name=q2; cd $name
	trap 'echo "$name: たぶんなんか間違ってます"; exit 1' ERR

	for i in $(seq 1 ${MAX}); do
		file=$(printf "%04g" $i).txt
		if [ $(( $i % 3 )) = 0 ] || [ $(( $i % 5 )) = 0 ]; then
			[ ! -f $file ]
			continue
		fi
		find . -name $file | xargs grep -q -E "data $i$"
	done
	cd - >/dev/null
	echo "$name: たぶん正解です、たぶん"
}

mk_q3() {
	name=q3; rm -rf $name; mkdir -p $name; cd $name
	echo "$name: 0001.tar ... 1000.tar がある。解凍せよ。"
	echo "    ただし、tarファイルの中身は不明であることに注意せよ。"

	for i in $(seq 1 ${MAX}); do
		file=$(printf "%04g" $i).txt
		tarfile=$(printf "%04g" $i).tar

		if [ $(( $i % 3 )) = 0 ]; then
			# 重複するファイル名
			file=hoge$(($i / 3 % 5)).txt
			echo "data $i" > $file
			tar --remove-files -cf $tarfile $file
		elif [ $(( $i % 5 )) = 0 ]; then
			# 重複するディレクトリとファイル
			dir=fuga$(($i / 5 % 3))
			mkdir -p $dir
			echo "data $i" > $dir/$file
			tar --remove-files -cf $tarfile $dir
		else
			echo "data $i" > $file
			tar --remove-files -cf $tarfile $file
		fi
	done
	cd - >/dev/null
}
assert_q3() {
	name=q3; cd $name
	trap 'echo "$name: たぶんなんか間違ってます"; exit 1' ERR

	for i in $(seq 1 ${MAX}); do
		if [ $(( $i % 3 )) = 0 ]; then
			file=hoge$(($i / 3 % 5)).txt
			find . -name $file | xargs grep -q -E "data $i$"
		elif [ $(( $i % 5 )) = 0 ]; then
			dir=fuga$(($i / 5 % 3))
			file=$(printf "%04g" $i).txt
			mkdir -p $dir
			find . -name $file | xargs grep -q -E "data $i$"
		else
			file=$(printf "%04g" $i).txt
			find . -name $file | xargs grep -q -E "data $i$"
		fi

		find . -name $file | xargs grep -q -E "data $i$"
	done
	cd - >/dev/null
	echo "$name: たぶん正解です、たぶん"
}


case "${1:-}" in
	make)
		if [ -z ${2:-} ]; then
			for func in $(grep -E "^mk_q" $0|sed -E "s/\(.*//"); do
				$func
			done
		else
			mk_${2:-}
		fi
		;;
	assert)
		if [ -z ${2:-} ]; then
			for func in $(grep -E "^assert_q" $0|sed -E "s/\(.*//"); do
				$func
			done
		else
			assert_${2:-}
		fi
		;;
	*|help|h)
		echo "Usage: $0 MODE [q\${num}]"
		echo "  MODE: make|assert"
		;;
esac
