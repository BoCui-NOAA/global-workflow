
PDY=20200213

COM_d=/lfs/h2/emc/vpppg/noscrub/bo.cui/BUFR/data_bufr_ctl/hr3scoutC768
COM_d=/lfs/h2/emc/vpppg/noscrub/bo.cui/BUFR/data_bufr_ctl/hr3scoutC1152


dir=gfs.${PDY}/00/model_data/atmos/history
file=gfs.t00z.atmf024.nc
ncdump -h $COM_d/$dir/$file

