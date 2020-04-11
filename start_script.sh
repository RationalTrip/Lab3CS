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

exe_file="exe$1"
logFile="log$1.txt"

#Remove log if exists
rm -f $logFile

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

calc_time() {
        local res=$((time -p ./$exe_file) 2>&1 | cat)
        local lExecTime=$( echo $res | grep real | awk '{print $2}' )

        echo "$lExecTime";
}

echo $'\n'$'\n'"Individual -O optimization flags" >> $logFile

for flag in ${oFlags[@]}; do
        $CC $std -$flag -o $exe_file $source
        echo "$flag $(calc_time)" >> $logFile
done

echo $'\n'$'\n'"-$x optimization flags alongside -Ofast." >> $logFile

for ext in ${cpuExts[@]}; do
        $CC $std -Ofast -$x$ext -o $exe_file $source
        echo "$ext $(calc_time)" >> $logFile
done