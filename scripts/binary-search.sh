#!/bin/bash

changesets_dir='/nightly/changesets/mainline/linux'

if [ $# -lt 6 ]
then
    echo -e "Usage:\n$0 comp_id_1 comp_id_2 runtime_1 runtime_2 config march"
    exit 1
fi

comp_id_1=$1
comp_id_2=$2
runtime_1=$3
runtime_2=$4
config=$5
march=$6

if [[ "$comp_id_1" > "$comp_id_2" ]]
then
    echo 'Error: comp_id_1 should be less or equal to comp_id_2'
    exit 2
fi

if [[ "$march" == "Montecito" || "$march" == "montecito" ]]
then
    queue_name='Mntct-1'
else
    if [[ "$march" == "Montvale" || "$march" == "montvale" ]]
    then
        queue_name='Mntvl-1'
    else
        echo March $march does not exist or was not specified
        exit 3
    fi
fi

dump_all()
{
    local i=0
    for c in ${changesets[@]}
    do
        echo "${changesets[$i]} ${runtime[$i]}"
        let "i += 1"
    done
} # eof dump_all()

get_changesets()
{
    local i=0
    for c in ${changesets_dir}/*
    do
        local comp_id=`basename $c`

        if [[ "$comp_id" > "$comp_id_1" && $i -eq 0 ]]
        then
            changesets[0]=$prev_id
            i=1
        else
            local prev_id=$comp_id
        fi

        if [ $i -ne 0 ]
        then
            if [[ "$comp_id" < "$comp_id_2" ]]
            then
                if [ -d ${changesets_dir}/${comp_id}/build/release/bin ]
                then
                    changesets[$i]=$comp_id
                else
                    let "i -= 1"
                fi
            else
                break
            fi

            let "i += 1"
        fi
    done
    let "i -= 1"

    i_beg=0
    i_end=$i

    runtime[$i_beg]=$runtime_1
    runtime[$i_end]=$runtime_2
} # eof get_changesets()

calc_degr()
{
    degr=`echo "scale=4; ${runtime[$p1]}/${runtime[$p2]}-1 <= -0.02" | bc`
} # eof calc_degr()

binary_search()
{
    run_test()
    {
        local conf_temp='temp.cfg'
        local ch_1=${changesets[$i_1]}
        local ch_2=${changesets[$i_2]}
        local dir="$ch_1-$ch_2"

        echo Running perf with compilers $ch_1 and $ch_2...

        mkdir $dir
        cd $dir
        cp ../run_test.sh .
        cp ../get_result.sh .
        cp ../$config ./$conf_temp
        echo experimental compiler $ch_1 >> $conf_temp
        echo reference compiler $ch_2 >> $conf_temp
        echo experimental path ${changesets_dir}/$ch_1/build/release/bin >> $conf_temp
        echo reference path ${changesets_dir}/$ch_2/build/release/bin >> $conf_temp

        queue ./run_test.sh $conf_temp -q $queue_name

        local suite=`awk '/test suite/ {print $3;}' $conf_temp`
        while [ ! -f ${suite}.res ]
        do
            sleep 5
        done

        if [ ! -s ${suite}.res ]
        then
            echo perf error
            exit 5
        fi

        local pass=`awk '/expruntime/ {print $3;}' ${suite}.res`
        if [ $pass -ne 1 ]
        then
            echo perf error
            exit 5
        fi

        local rt_1=`awk '/expruntime/ {print $2;}' ${suite}.res`
        local rt_2=`awk '/refruntime/ {print $2;}' ${suite}.res`

        runtime[$i_1]=$rt_1
        runtime[$i_2]=$rt_2

        cd ..
        rm -r $dir
    }

    calc_degr

    if [ $degr -eq 0 ]
    then
        echo Error: the degradation is less than 2%
        exit 4
    fi

    let "diff = p2 - p1"

    if [ $diff -le 1 ]
    then
        return
    fi

    if [ $diff -eq 2 ]
    then
        let "i_1 = p1 + 1"
        let "i_2 = p1 + 1"
        run_test
        return
    fi

    let "c = diff / 3"
    let "b = (diff-c) / 2"
    let "a = diff-c-b"
    let "i_1 = p1 + a"
    let "i_2 = p1 + a + b"

    run_test

    p1=$i_2
    p2=$i_end
    calc_degr
    if [ $degr -eq 1 ]
    then
        binary_search
        return
    fi

    p1=$i_1
    p2=$i_2
    calc_degr
    if [ $degr -eq 1 ]
    then
        binary_search
        return
    fi

    p1=$i_beg
    p2=$i_1
    calc_degr
    if [ $degr -eq 1 ]
    then
        binary_search
        return
    fi

    echo Error: the degradation is less than 2%
    exit 4
} # eof binary_search()



# Begin

# Get changesets between $comp_id_1 and $comp_id_2
get_changesets

if [ `expr $i_end - $i_beg` -le 2 ]
then
    echo Error: no changeset builds between $comp_id_1 and $comp_id_2
    exit 6
fi

# Start binary search
p1=$i_beg
p2=$i_end
binary_search

# Dump changesets with runtimes
#dump_all
#echo ---

# Find last regression >= 2%
i=$i_end
prev=''
for c in ${changesets[@]}
do
    if [ ${runtime[$i]} > 0 ]
    then
        if [ $prev > 0 ]
        then
            p1=$i
            p2=`expr $i + 1`
            calc_degr
            if [ $degr -eq 1 ]
            then
                echo ${changesets[$p1]}
                echo ${changesets[$p2]}
                exit
            fi
        fi

        prev=${runtime[$i]}
    else
        prev=''
    fi

    let "i -= 1"
done

echo Error: the degradation is less than 2%
exit 4

# The End
