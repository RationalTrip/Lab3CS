#!/bin/bash

#./start_script.sh [debug_name] [sourse_file] [compiler] 

source="$2"
CC="$3"

#Check is CC g++ or icc
if [[ "$CC" == "g++" ]]; then
	std="-std=c++11"
	x="m"
else
	std="-std=c++14"
	x="x"
	ml icc
fi

exeFile="exe$1"
tmpFile="tmp$1.txt"
logFile="log$1.txt"

#Remove log if exists
rm $logFile 2> /dev/null 

# Compiler flags
oFlags=(O0 O1 O2 O3 Ofast)

# Possible CPU SIMD extensions
possibleExts=(sse2 sse3 ssse3 sse4.1 sse4.2 avx)
cpuExts=()

for possibleExt in ${possibleExts[@]}; do
	if lscpu | grep Flags | grep -qw $possibleExt; then
		cpuExts+=($possibleExt)
	fi
done

echo "Cpu extensions: ${cpuExts[*]}"$'\n'$'\n' >> $logFile

calcResAndTime() {
	local lExecTime=$( ( time -p ./$exeFile > $tmpFile ) 2>&1 | grep real | awk '{print $2}' )
	local lExecRes=$( cat $tmpFile | awk '{sum=(sum+$1)%1000}END{print sum}' )
	echo "$lExecRes $lExecTime";
}

echo "Testing individual -O optimization flags" >> $logFile
echo "Flag Result Time" >> $logFile

for flag in ${oFlags[@]}; do
	$CC $std -$flag -o $exeFile $source
	echo "$flag $(calcResAndTime)" >> $logFile
done

echo "Testing -$x optimization flags (for some supported CPU extensions) alongside -Ofast." >> $logFile
echo "Extension Result Time" >> $logFile

for ext in ${cpuExts[@]}; do
	$CC $std -Ofast -$x$ext -o $exeFile $source
	echo "$ext $(calcResAndTime)" >> $logFile
done