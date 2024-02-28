
debufr=/apps/ops/prod/nco/intel/19.1.3.304/util_shared.v1.4.0/bin/debufr

PDY=20200213

COM_1152=/lfs/h2/emc/ptmp/bo.cui/com_hr3scoutC1152/gfs/prod/gfs.20200213/00/products/atmos/bufr
COM_768=/lfs/h2/emc/ptmp/bo.cui/com_hr3scoutC768/gfs/prod/gfs.20200213/00/products/atmos/bufr

file=bufr.999902.2020021300

$debufr $COM_1152/$file -o outbufr_c1152
$debufr $COM_768/$file -o outbufr_c768

