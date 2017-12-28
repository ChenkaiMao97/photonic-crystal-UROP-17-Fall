outname='../data.dat'
echo "#ky freq Q" > $outname

cd output

# get the output files and sort and take away other output files
list=`ls *.out | cut -d. -f1 | sort -n | awk '{if ($1+0==$1) print $1}'`

for n in $list
do
    file=$n.out
    grep wade $file | awk '{printf("%.7f\n", $4)}' > temp
    grep harminv $file | tail -n +2 | cut -d, -f2,4 | sed 's/,/ /' | awk '{printf("%15.13f %.0f\n",$1,$2)}' >> temp
    if [ `wc -l temp | awk '{print $1}'` -eq 1 ]
    then
        echo -n "#" >> $outname
    fi
    awk 'BEGIN{ORS=" "}{print $0}' temp >> $outname
    echo >> $outname
done
rm temp
