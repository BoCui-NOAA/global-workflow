
PDY=20200213

COM_d1=/lfs/h2/emc/vpppg/noscrub/bo.cui/BUFR/data_bufr_ctl/hr3scoutC768
COM_d2=/lfs/h2/emc/vpppg/noscrub/bo.cui/BUFR/data_bufr_ctl/hr3scoutC1152


dir=gfs.${PDY}/00/model_data/atmos/history
file=gfs.t00z.atmf024.nc

ls $COM_d1/$dir

echo 
ls $COM_d2/$dir

exit
ncdump -h $COM_d/$dir/$file

