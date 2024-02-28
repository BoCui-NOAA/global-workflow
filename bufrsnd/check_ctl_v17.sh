#!/bin/sh
set -x
echo 'into'
#.gempak
#. /nwprod/gempak/.gempak
#. /opt/modules/default/init/sh
module load gempak/7.14.1

mkdir WORK
sWS=`pwd`/WORK

## sh make_soundings_1stat

fromWho=cui 
hr00=${hr00:-00} #12
da00=20210823
month=`echo $da00 |cut -c5-6`
day=`echo $da00 |cut -c7-8`
mems=${mems:-"gfs"} # c00 p01 p02 p10 p15 p20 p25 p30"} #avg c00 p01 p02 p03 p04 p05" 

stations="000740" # 003357 727930 724060 725090 724930 000229 724510 727120" #\
 #         724030 725180 722010 725010 722080 724560 723630 724560 723570 \
 #         725580 745600 723270 725620 727640 725720 724690 726490 726810 \
 #         724930 722930 727860 723650 702730 701330 912850 722350 727680 \
 #         722650 722500 722480 722740 725970 726620 726320 723180 722490 \
 #         722150 725820 911650 912120"
stations="912120 727860 "
stations="724930 722930 727860"
stations="912120 724930 "
export homedir=`pwd`
export outdir=`pwd`/ops_para_plots_test

mkdir -p ${outdir}/${fromWho}/${hr00} 
rm ${outdir}/${fromWho}/${hr00}/*gif*

echo ${outdir}/${fromWho}/${hr00}
ls ${outdir}/${fromWho}/${hr00}

times="000 006 012 018 024 036 048 060 072 084 096 120 150 180" # 006 012 018 024 048 060 120 180" # 012 018 024 036 048 072 120" #xxw
#times="00 24 48 72 96 120 144 168 180"
times="00 24 48 72 96 120 144 168 180"
times="24 120 180"
times="12 24 "

#COM1=/lfs/h1/ops/prod/com/gfs/v16.2/gfs.$da00/$hr00/atmos/gempak
COM1=/lfs/h1/ops/canned/com/gfs/v16.2/gfs.$da00/$hr00/atmos/gempak
COM2=/lfs/h2/emc/ptmp/$LOGNAME/com_bufr/gfs/prod/gfs.$da00/$hr00/products/atmos/gempak

cd $sWS
rm gfs_${da00}${hr00}.snd_ctl 
rm gfs_${da00}${hr00}.snd
cp $COM1/gfs_${da00}${hr00}.snd gfs_${da00}${hr00}.snd_ctl
cp $COM2/gfs_${da00}${hr00}.snd gfs_${da00}${hr00}.snd

for mem in $mems; do

    fsnd_0=gfs_${da00}${hr00}.snd_ctl 
    fsnd_1=gfs_${da00}${hr00}.snd 

    for fhr in $times; do

        validtime="`${homedir}/advtime ${da00}${hr00} $fhr -1 x`"
        dattim=`echo $validtime | cut -c5-11`
        echo $validtime $dattim
 
        for stnm in $stations; do
            # negate the colors ahead of time except white and black
			gpcolor <<- EOFC
				COLORS=0=255:255:255?
				COLORS=101=255:255:255;1=0:0:0
				DEVICE   = GF
				r
				
				ex
				EOFC

    		snprof <<- EOF
				SNFILE   = $fsnd_0
				DATTIM   = $dattim
				AREA     = @${stnm}
				SNPARM   = tmpc;dwpc
				LINE     = 4;4/10;10/8
				PTYPE    = skewt
				VCOORD   = PRES
				STNDEX   = lift;cape;cins
				STNCOL   = 24
				WIND    =  bm4//2
				WINPOS   = 1
				MARKER   = 0
				BORDER   = 1//2
				TITLE    = 4// "Fcst hr:$fhr; prod-BLUE;            "
				DEVICE   = gf|${mem}_${stnm}_${da00}${hr00}f${fhr}_2T.gif|650;750
				YAXIS    = 1050/100/100/1;1;1
				XAXIS    = -40/35/10/;1
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

			snprof <<- EOF2
				SNFILE   = $fsnd_1
				LINE     = 2;2/1;1/2
				WIND    =  bm2//2
				TITLE    = 2// "                           para-RED"
				CLEAR    = n
				WINPOS   = 2
				r
				
				ex
				EOF2

		    gpend
		    rm gemglb.nts last.nts

            convert ${mem}_${stnm}_${da00}${hr00}f${fhr}_2T.gif  -crop 614x600+6+74 +repage  ${mem}_${stnm}_${da00}${hr00}f${fhr}_2T.gif
            ##convert ${stnm}_${da00}${hr00}f${fhr}_2T.gif  -trim +repage  ${stnm}_${da00}${hr00}f${fhr}_2T.gif
            mv ${mem}_${stnm}_${da00}${hr00}f${fhr}_2T.gif ${outdir}/${fromWho}/${hr00}/
        #exit
        done
    done

    cd ${outdir}/${fromWho}/${hr00}
#   for stnm in $stations; do
#       convert -delay 60 -loop 0 ${mem}_${stnm}_${da00}${hr00}f*_2T.gif ${mem}_${stnm}_${da00}${hr00}.gif
#   done
done

cd ${outdir}/${fromWho}/${hr00}

dir_main=/home/people/emc/www/htdocs/gmb/wx20cb/BUFR
dir_new=sample.$da00${hr00}_ctlgfsv17

ssh -l bocui emcrzdm "mkdir ${dir_main}/${dir_new}"
ssh -l bocui emcrzdm "cp ${dir_main}/a* ${dir_main}/${dir_new}"
ssh -l bocui emcrzdm "cp ${dir_main}/i* ${dir_main}/${dir_new}"
ssh -l bocui emcrzdm "echo $dir_new > ${dir_main}/dir_new.txt"
ssh -l bocui emcrzdm "cat ${dir_main}/dir_new.txt >> ${dir_main}/allow.cfg"
scp *.gif      bocui@emcrzdm:${dir_main}/$dir_new

echo abouttoexitsnd
exit



# --------------------------------------------------------------
## 000740 39.58N  79.34W K2G4 11 OAKLAND, MD                 894
## 003357 33.00S  57.00W URU  11 CENTRAL URUGUAY               0
## 727930 47.45N 122.30W KSEA 10 SEATTLE-TACOMA_INTL WA      137
## 724060 39.18N  76.67W KBWI 10 BALTIMORE/WASH_INTL     MD   47
## 723530 35.40N  97.60W KOKC 10 OKLAHOMA_CITY(AWOS)     OK  397
## 723570 35.23N  97.47W OUN  12 NORMAN  OK              OK  358
## 725090 42.37N  71.03W KBOS 10 BOSTON/LOGAN_INTL_&     MA    9
## 724930 37.73N 122.22W KOAK 12 OAKLAND                 CA    3
## 000229 46.91N 124.11W WPT  12 WESTPORT WA                -999
#724030 38.95N  77.44W KIAD 12 WASHINGTON/DULLES       VA   98 UA NA110 TAF 2-99              
#725180 42.75N  73.80W KALB 12 ALBANY_COUNTY_ARPT      NY   89 UA NA110 FOUS TAF 2-99         
#722010 24.55N  81.75W KEYW 22 KEY_WEST_INTL_ARPT      FL    6 UA NA110 TAF 2-99              
#725010 40.87N  72.86W OKX  12 BROOKHAVEN              NY   20 NEW UPA                        
#722080 32.90N  80.03W KCHS 12 CHARLESTOWN_MUNI        SC   15 UA NA110 FOUS TAF 2-99         
#724560 39.07N  95.62W KTOP 12 TOPEKA/BILLARD_MUNI     KS  270 UA NA110 FOUS TAF 2-99         
#723630 35.23N 101.70W KAMA 12 AMARILLO_ARPT(AWOS)     TX 1099 UA NA110 TAF 2-99              
#724560 39.07N  95.62W KTOP 12 TOPEKA/BILLARD_MUNI     KS  270 UA NA110 FOUS TAF 2-99         
#723570 35.23N  97.47W OUN  12 NORMAN  OK              OK  358 UA NA110 3-93                  
#725580 41.32N  96.37W OAX  12 OMAHA/VALLEY            NE  350 NEW UPA                        
#745600 40.15N  89.33W ILX  12 LINCOLN                 IL  176 GCIP 9-95                      
#723270 36.13N  86.68W KBNA 10 NASHVILLE_METRO         TN  180 TAF 2-99                       
#725620 41.13N 100.68W KLBF 12 N._PLATTE/LEE_BIRD      NE  849 UA NA110 FOUS TAF 2-99         
#727640 46.77N 100.75W KBIS 12 BISMARCK_MUNICIPAL      ND  506 UA NA110 FOUS TAF 2-99         
#725720 40.78N 111.97W KSLC 12 SALT_LAKE_CITY_INTL     UT 1288 UA NA110 FOUS TAF 2-99         
#724690 39.75N 104.87W DEN  12 DENVER/STAPLETON        CO 1611 UA NA110 FOUS                  
#726490 44.85N  93.57W MPX  12 CHANHAUSSEN             MN  289 GCIP 9-95                      
#726810 43.57N 116.22W KBOI 12 BOISE_MUNICIPAL         ID  874 UA NA110 FOUS TAF 2-99         
#724930 37.73N 122.22W KOAK 12 OAKLAND                 CA    3 UA NA110 TAF 2-99              
#722930 32.85N 117.12W NKX  12 MIRAMAR_NAS_______&     CA  128 UA NA110 3-93                  
#727860 47.70N 117.60W KOTX 12 SPOKANE                 WA  728 UA 3-02                        
#723650 35.05N 106.62W KABQ 12 ALBUQUERQUE_INTL        NM 1620 UA NA110 FOUS TAF 2-99         
#702730 61.17N 150.02W PANC 12 ANCHORAGE_INTL_ARPT_(AS AK   40 GCIP 9-95 TAF 2-99             
#701330 66.87N 162.63W PAOT 10 KOTZEBUE/RALPH_WIEN_(AS AK    5 UA ALA23 FOUS TAF 2-99         
#912850 19.72N 155.07W PHTO 10 HILO/LYMAN_FIELD_(ASOS) HI   11 UA FOUS 4-93 TAF 2-99          

#724510 37.77N  99.97W KDDC 12 DODGE_CITY(AWOS)        KS  790 UA NA110 FOUS TAF 2-99
#727120 46.87N  68.01W KCAR 12 CARIBOU_MUNICIPAL       ME  190 UA NA110 FOUS TAF 2-99
#722350 32.32N  90.08W KJAN 12 JACKSON/THOMPSON        MS  101 UA NA110 FOUS TAF 2-99
#727680 48.22N 106.62W KGGW 12 GLASGOW_INTL_ARPT       MT  700 UA NA110 FOUS TAF 2-99
#722650 31.95N 102.18W KMAF 12 MIDLAND_REGIONAL        TX  872 UA NA110 FOUS TAF 2-99
#722500 25.90N  97.43W KBRO 12 BROWNSVILLE_INTL        TX    6 UA NA110 FOUS TAF 2-99
#722480 32.47N  93.82W KSHV 12 SHREVEPORT_REGIONAL     LA   79 WSR88D FOUS TAF 2-99
#722740 32.12N 110.93W KTUS 12 TUCSON_INTL_AIRPORT     AZ  779 UA NA110 TAF 2-99
#725970 42.37N 122.87W KMFR 12 MEDFORD/JACKSON_CO.     OR  405 UA NA110 FOUS TAF 2-99
#726620 44.06N 103.05W KRAP 12 RAPID_CITY_REGIONAL     SD  966 UA NA110 FOUS TAF 2-99
#726320 42.70N  83.47W DTX  10 DETROIT/PONTIAC         MI  319 UA GCIP 9-95
#723180 37.21N  80.41W KRNK 12 BLACKSBURG/ROANOKE UA   VA  653 UA 3-02

