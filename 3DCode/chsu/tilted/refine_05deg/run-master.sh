# read params
if [ $# -ne 5 ]
then
    echo 'usage: sh run-mater.sh ky_max total_cores input_name np out_folder'
    exit
fi
ky_max=$1
total_cores=$2

#fname='input.dat'
fname=$3
np=$4
sub_script='../run.sh'
ctl_name='../band-tm.ctl'
#out_folder='output'
out_folder=$5
run_out_folder='run-out'

echo "running on $HOSTNAME"

n_jobs=`wc -l $fname | awk '{print $1}'`
echo $n_jobs "jobs to run"

mkdir $out_folder
mkdir $run_out_folder

# distribute the work
if test `expr $n_jobs % $total_cores` -eq 0
then
    jobs_per_core=`expr $n_jobs / $total_cores`
else
    jobs_per_core=`expr $n_jobs / $total_cores + 1`
    total_cores=`expr $n_jobs / $jobs_per_core`
    if test `expr $n_jobs % $jobs_per_core` -ne 0
    then
        total_cores=`expr $total_cores + 1`
    fi
fi
echo "using $total_cores cores, with $jobs_per_core on each core"

# run the jobs
temp=`expr $total_cores - 2`
for n in `seq 0 $temp`
do
    n_start=`expr $n \* $jobs_per_core + 1`
    n_end=`expr $n_start + $jobs_per_core - 1`
    echo $n_start $n_end
    sh $sub_script $ky_max $n_start $n_end $fname $ctl_name $out_folder $np > $run_out_folder/$n_start.out 2>&1 &
done
n_start=`echo "($total_cores-1)*$jobs_per_core+1" | bc`
n_end=$n_jobs
echo $n_start $n_end
sh $sub_script $ky_max $n_start $n_end $fname $ctl_name $out_folder $np > $run_out_folder/$n_start.out 2>&1 &
