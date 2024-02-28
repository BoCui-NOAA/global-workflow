#! /usr/bin/env bash

#
#  UTILITY SCRIPT NAME :  gfsbufr.sh
#               AUTHOR :  Hua-Lu Pan
#         DATE WRITTEN :  02/03/97
#
#  Abstract:  This utility script produces BUFR file of
#             station forecasts from the GFS suite.
#
#     Input:  none
# Script History Log:
# 2016-10-30  H Chuang: Tranistion to read nems output.
#             Change to read flux file fields in gfs_bufr
#             so remove excution of gfs_flux
# 2018-03-22 Guang Ping Lou: Making it works for either 1 hourly or 3 hourly output
# 2018-05-22 Guang Ping Lou: Making it work for both GFS and FV3GFS 
# 2018-05-30  Guang Ping Lou: Make sure all files are available.
# 2019-10-10  Guang Ping Lou: Read in NetCDF files
# 2023-12-18  Bo Cui: modified to allow midstream restart
# echo "History: February 2003 - First implementation of this utility script"
#
source "${HOMEgfs:?}/ush/preamble.sh"

if [[ "${F00FLAG}" == "YES" ]]; then
   f00flag=".true."
else
   f00flag=".false."
fi

export pgm="gfs_bufr.x"
#. prep_step

if [[ "${MAKEBUFR}" == "YES" ]]; then
   bufrflag=".true."
else
   bufrflag=".false."
fi

##fformat="nc"
##fformat="nemsio"

CLASS="class1fv3"
cat << EOF > gfsparm
 &NAMMET
  levs=${LEVS},makebufr=${bufrflag},
  dird="${COM_ATMOS_BUFR}/bufr",
  nstart=${FSTART},nend=${FEND},nint=${FINT},
  nend1=${NEND1},nint1=${NINT1},nint3=${NINT3},
  nsfc=80,f00=${f00flag},fformat=${fformat},np1=0
/
EOF

for (( hr = 10#${FSTART}; hr <= 10#${FEND}; hr = hr + 10#${FINT} )); do
   hh2=$(printf %02i "${hr}")
   hh3=$(printf %03i "${hr}")

   #---------------------------------------------------------
   # Make sure all files are available:
   ic=0
   while (( ic < 1000 )); do
      if [[ ! -f "${COM_ATMOS_HISTORY}/${RUN}.${cycle}.atm.logf${hh3}.${logfm}" ]]; then
          sleep 10
          ic=$((ic + 1))
      else
          break
      fi

      if (( ic >= 360 )); then
         echo "FATAL: COULD NOT LOCATE logf${hh3} file AFTER 1 HOUR"
         exit 2
      fi
   done
   #------------------------------------------------------------------
   ln -sf "${COM_ATMOS_HISTORY}/${RUN}.${cycle}.atmf${hh3}.${atmfm}" "sigf${hh2}" 
   ln -sf "${COM_ATMOS_HISTORY}/${RUN}.${cycle}.sfcf${hh3}.${atmfm}" "flxf${hh2}"
done

#  define input BUFR table file.
ln -sf "${PARMbufrsnd}/bufr_gfs_${CLASS}.tbl" fort.1
ln -sf "${STNLIST:-${PARMbufrsnd}/bufr_stalist.meteo.gfs}" fort.8
ln -sf "${PARMbufrsnd}/bufr_ij13km.txt" fort.7

if [ $resterr -eq 0 ]; then

  echo "Copy restart files for GFS postsnd job"
  if [ -f ${COM_ATMOS_RESTART}/${RUN}.${cycle}.bufr.logf${FEND}.${logfm} ]; then
    cp -p ${COM_ATMOS_RESTART}/${RUN}.${cycle}.bufr.logf${FEND}.${logfm} .
    while IFS= read -r fortname; do
      echo "Processing file: $fortname"
      cp -p ${COM_ATMOS_RESTART}/${RUN}.${cycle}.bufr_${fortname} ${fortname}
    done < ${RUN}.${cycle}.bufr.logf${FEND}.${logfm}
    err=0

  else
    echo "set resterr=1 for GFS postsnd, no RESTART files "
    export resterr=1
    ${APRUN_POSTSND} "${EXECbufrsnd}/${pgm}" < gfsparm > "out_gfs_bufr_${FEND}"
    export err=$?
  fi

else

  ${APRUN_POSTSND} "${EXECbufrsnd}/${pgm}" < gfsparm > "out_gfs_bufr_${FEND}"
  export err=$?
fi

if [ $err -ne 0 ]; then
   echo "GFS postsnd job error, Please check files "
   echo "${COM_ATMOS_HISTORY}/${RUN}.${cycle}.atmf${hh2}.${atmfm}"
   echo "${COM_ATMOS_HISTORY}/${RUN}.${cycle}.sfcf${hh2}.${atmfm}"
   err_chk
else

# List files matching the pattern fort.*, excluding fort.1 and fort.9, and save to a txt file

   echo "copy GFS postsnd data to restart directory "
   ls fort.* | grep -v -e 'fort\.1' -e 'fort\.7'  -e 'fort\.8' > ${RUN}.${cycle}.bufr.logf${FEND}.${logfm} 
   cp -p ${RUN}.${cycle}.bufr.logf${FEND}.${logfm} ${COM_ATMOS_RESTART}/

# Read each line from the txt file
  while IFS= read -r fortname; do
    echo "Processing file: $fortname"
    cp -p ${fortname}  ${COM_ATMOS_RESTART}/${RUN}.${cycle}.bufr_${fortname}        
  done < ${RUN}.${cycle}.bufr.logf${FEND}.${logfm}

fi

exit ${err}
