#!/bin/bash

if [ $# -ne 2 ];
then
    echo "Usage: $0 config_file events_file"
    exit 1
fi

temp_dir=`date +%s`
config_file="$1"
events_file="$2"
events_count=`wc --lines < ${events_file}`

mbq_queue=`awk '/Queue/ {split($0, a, /= /); print a[2];}' ${config_file}`
mbq_priority=`awk '/Priority/ {split($0, a, /= /); print a[2];}' ${config_file}`
exec1=`awk '/Executable 1/ {split($0, a, /= /); print a[2];}' ${config_file}`
exec2=`awk '/Executable 2/ {split($0, a, /= /); print a[2];}' ${config_file}`
input_file=`awk '/Input file/ {split($0, a, /= /); print a[2];}' ${config_file}`
params=`awk '/Params/ {split($0, a, /= /); print a[2];}' ${config_file}`
periods=`awk '/Periods/ {split($0, a, /= /); print a[2];}' ${config_file}`
output_file=`awk '/Output file/ {split($0, a, /= /); print a[2];}' ${config_file}`

echo -e "Queue:\t\t${mbq_queue}"
echo -e "Priority:\t${mbq_priority}"
echo -e "Executable 1:\t${exec1}"
echo -e "Executable 2:\t${exec2}"
echo -e "Input file:\t${input_file}"
echo -e "Params:\t\t${params}"
echo -e "Periods:\t${periods}"
echo -e "Output file:\t${output_file}"
echo "${events_count} events: "
cat ${events_file}

mkdir ${temp_dir}
cd ${temp_dir}

while read event;
do
    mbq -p ${mbq_priority} ../run_pfmon.sh "1 ${periods} ${event} ../${exec1} ../${input_file} ${params}" -q ${mbq_queue}
    mbq -p ${mbq_priority} ../run_pfmon.sh "2 ${periods} ${event} ../${exec2} ../${input_file} ${params}" -q ${mbq_queue}
done < ../${events_file}
echo && echo

i=0
events_count=$((2*$events_count))
while [ $i -ne $events_count ];
do
    up=$(($i+1))
    echo -e "\033[${up}A\033[KFinished:"

    i=0
    for f in $( find . -maxdepth 1 -name "*.[1-2].count" );
    do
        basename $f .count
        i=$(($i+1))
    done

    sleep 5
done

while read event;
do
    count1=`cat ${event}.1.count`
    count2=`cat ${event}.2.count`

    if [ ${count1} -gt 0 ];
    then
        diff=`echo "scale=2; 100*${count2}/${count1}-100" | bc`
    else
        diff="..."
    fi

    echo -e "${event}\t${count1}\t${count2}\t${diff}%" >> ${output_file}.unsorted
done < ../${events_file}

sort --numeric-sort --reverse --key=4 ${output_file}.unsorted > ../${output_file}

for f in mb-*.err;
do
    if [ -s $f ];
    then
        echo "Error in $f: "
        cat $f
        echo
    fi
done

cd ..
rm -rf ${temp_dir}
