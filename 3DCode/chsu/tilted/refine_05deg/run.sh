if [ $# -ne 7 ]
then
    echo 'usage: sh run.sh ky_max line_start line_end fname ctl_name out_folder np'
    exit
fi

ky_max=$1
n_start=$2
n_end=$3
fname=$4
ctl_name=$5
out_folder=$6
np=$7

tempfile=temp"$n_start".inp

for n in `seq $n_start $n_end`
do
    # read info
    head -$n $fname | tail -1 > $tempfile
    kx=`awk '{print $1}' $tempfile`
    ky=`echo $kx*$ky_max/0.5 | bc -l`
    fcen=`awk '{print $2}' $tempfile`

    # make them standard format
    #kx=`echo $kx | awk '{printf("%.6f",$1)}'`
    #ky=`echo $ky | awk '{printf("%.6f",$1)}'`

    # stdout and h5 output files
    outname=$out_folder/$n.out

    date
    echo "running kx = $kx, ky = $ky, f = $fcen ..."

    # run the job
    echo "wade: kx = $kx ; ky = $ky " > $outname
    mpirun -np $np /home/bermel/install/bin/meep-mpi kx=$kx ky=$ky fcen=$fcen $ctl_name >> $outname 2>&1

    echo "done"
    echo
done
rm $tempfile
