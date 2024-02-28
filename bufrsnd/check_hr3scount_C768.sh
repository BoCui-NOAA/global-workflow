#!/bin/sh
set -x
echo 'into'
#.gempak
#. /nwprod/gempak/.gempak
#. /opt/modules/default/init/sh
module load gempak/7.14.1

## sh make_soundings_1stat

stations="912120"
stations="745600 912120 "

cyc=00
da00=20200213
#da00=$1
#cyc=$2
month=`echo $da00 |cut -c5-6`
day=`echo $da00 |cut -c7-8`

#export homedir=/lfs/h2/emc/ptmp/$LOGNAME/bufrsnd
export homedir=`pwd`
#export datadir=/lfs/h2/emc/ptmp/$LOGNAME/com_bufr/gfs/prod/gfs.$da00/gempak
export datadir=/lfs/h2/emc/ptmp/$LOGNAME/com_hr3scoutC768/gfs/prod/gfs.$da00/$cyc/products/atmos/gempak
ls -l

cd $homedir
rm *gif
rm gfs_${da00}${cyc}.snd
cp $datadir/gfs_${da00}${cyc}.snd .

##times="180 177 174 171 168 "
#times="00 06 12 18 24 30 "
times="00 24 120 180"
times="24"
for fhr in $times; do

validtime="`${homedir}/advtime ${da00}${cyc} $fhr -1 x`"
dattim=`echo $validtime | cut -c5-11`
echo "validtime= " $validtime
echo "dattim= " $dattim

for stnm in $stations; do

#fmdl=${homedir}/data/gfs_${da00}${cyc}.snd
fmdl=${homedir}/gfs_${da00}${cyc}.snd
echo $fmdl

# negate the colors ahead of time except white and black
gpcolor << EOFC
COLORS=0=255:255:255?
COLORS=101=255:255:255;1=0:0:0
DEVICE   = GF
r
ex
EOFC

    snprof << EOF
 SNFILE   = $fmdl
 DATTIM   = $dattim
 AREA     = @${stnm}
 SNPARM   = tmpc;dwpc
 LINE     = 2;4/1/5
 PTYPE    = skewt
 VCOORD   = PRES
 STNDEX   = lift;cape;cins
 STNCOL   = 24
 WIND     = bk1
 WINPOS   = 1
 MARKER   = 0
 BORDER   = 1//2
 TITLE    = 1// $stnm  
 DEVICE   = gf|${stnm}gfssnd_${cyc}f${fhr}.gif|650;750
 YAXIS    = 1050/400/100/1;1;1
 XAXIS    = -20/45/10/;1
 FILTER   = 0.6
 CLEAR    = y
 PANEL    = 0
 TEXT     = 1.0
 THTALN   = 8/3/1/250/500/5
 THTELN   = 23/1/1/250/500/5
 MIXRLN   = 17/10/2/0/40./1.
r

ex
EOF

gpend
done
done

echo abouttoexitsnd

dir_main=/home/people/emc/www/htdocs/gmb/wx20cb/BUFR
dir_new=sample.$da00${cyc}_hr3scount_C768

ssh -l bocui emcrzdm "mkdir ${dir_main}/${dir_new}"
ssh -l bocui emcrzdm "cp ${dir_main}/a* ${dir_main}/${dir_new}"
ssh -l bocui emcrzdm "cp ${dir_main}/i* ${dir_main}/${dir_new}"
ssh -l bocui emcrzdm "echo $dir_new > ${dir_main}/dir_new.txt"
ssh -l bocui emcrzdm "cat ${dir_main}/dir_new.txt >> ${dir_main}/allow.cfg"
scp *.gif      bocui@emcrzdm:${dir_main}/$dir_new

exit
