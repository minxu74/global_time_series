#!/usr/bin/env bash


#ATTN: caseid should include the componenet names
module load nco


#default
chkvars=(cLitter cSoilFast cSoilMedium cSoilSlow)
chkvars=(cLitter)
#basepath=/global/cscratch1/sd/minxu/CMIP6_ILAMB/LS3MIP_MODEL/
#basepath=/global/project/projectdirs/acme/xyk/CBGC_outputs/CTC/BDRD/
basepath=/global/cscratch1/sd/cmip6/1pctCO2-E3SM/20191017.RUBISCO_CO21PCT_CNPCTC20TR_OIBGC.ne30_oECv3.compy/run/

itype="mip"

dpm=(31 28 31 30 31 30 31 31 30 31 30 31)

gsca=1.0; asca=1.0
gfac=0.0; afac=0.0

OPTIONS=hv:m:u:t:b:
LNGOPTS=help,basepath:,variable:,method:,Gscale:,Ascale:,Gfactor:,Afactor:,units:,itype:,modnam:,caseid:,strtyr:,stopyr:,wgtsum:,wgtavg:

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LNGOPTS --name "$0" -- "$@")

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi

eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -h|--help)
            echo "`basename $0` -h[--help] -b[--basepath] -v[--variable] -m[--method] [--Gsacle] [--Ascale] [--Gfactor] [--Afactor] -u[--units] -t[--itype]"
            shift 1
	    exit
            ;;
        -b|--basepath)
            basepath="$2"
            shift 2
            ;;
        -v|--variable)
            varinp="$2"
            shift 2
            ;;
        -m|--method)
            method=`echo "$2" | tr '[:upper:]' '[:lower:]'`
            shift 2
            ;;
        --Gscale)
            gsca="$2"
            shift 2
            ;;
        --Ascale)
            asca="$2"
            shift 2
            ;;
        --Gfactor)
            gfac="$2"
            shift 2
            ;;
        --Afactor)
            afac="$2"
            shift 2
            ;;
        -u|--units)
            cunit="$2"
            shift 2
            ;;
        -t|--itype)
            itype="$2"
            shift 2
            ;;
        --modnam)
            modnam="$2"
            shift 2
            ;;
        --caseid)
            caseid="$2"
            shift 2
            ;;
        --strtyr)
            strtyr="$2"
            shift 2
            ;;
        --stopyr)
            stopyr="$2"
            shift 2
            ;;
        --wgtsum)
            wgtsum="$2"
            shift 2
            ;;
        --wgtavg)
            wgtavg="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

echo ${method:2:1}, ${method:5:1}
echo ${method:0:2}, ${method:3:2}


function isFloat() {
   if [[ "$1" =~ ^-?[0-9]*[.,]?[0-9]*[eE]-?[0-9]+$ || "$1" =~ ^-?[0-9]*[.,]?[0-9]*$ ||  "$1" =~ ^-?[0-9]+$ ]]; then
      echo 0
   else
      echo 1
   fi
}

function ncdmnlst { ncks --cdl -m ${1} | cut -d ':' -f 1 | cut -d '=' -s -f 1 ; }


if [[ $(isFloat $gsca) == 1 ]]; then
    echo "no number for Gscale" $gsca ; exit
fi

if [[ $(isFloat $asca) == 1 ]]; then
    echo "no number for Ascale" $asca ; exit
fi

if [[ $(isFloat $gfac) == 1 ]]; then
    echo "no number for Gfactor" $gfac ; exit
fi

if [[ $(isFloat $afac) == 1 ]]; then
    echo "no number for Afactor" $afac ; exit
fi


echo $gsca $asca
echo $gfac $afac

echo $varinp $method

IFS=',' read -r -a chkvars <<< "$varinp"


nvrs=${#chkvars[@]}

if [[ $itype == 'mip' ]]; then
   realpath=$basepath
else
   echo "aggreate data ......"

   realpath='./temp4model'


   if [[ -z $modnam || -z $caseid || -z $strtyr || -z $stopyr ]]; then
      echo "please provide modnm and caseid and strtyr and stopyr when itype is not mip"
      exit
   fi

   mkdir -p $realpath/$modnam


   year_align=0
   ncfiles=''



   #historical file tempates
   # mpascice.hist.am.timeSeriesStatsMonthly.1881-05-01.nc
   # 20191017.RUBISCO_CO21PCT_CNPCTC20TR_OIBGC.ne30_oECv3.compy.cam.h0.1852-03.nc 

   for iy in `seq $((strtyr+year_align)) $((stopyr+year_align))`; do
       cy=`printf "%04d" $iy`

       if [[ $caseid == "mpas"* ]]; then
          ncfiles="$ncfiles "`/bin/ls ${basepath}/${caseid}.${cy}*.nc`
       else
          ncfiles="$ncfiles "`/bin/ls ${basepath}/${caseid}.h0.${cy}*.nc`
       fi

       if [[ $iy == $((strtyr+year_align)) ]]; then

	   if [[ $caseid == "mpas"* ]]; then
	      # mpaso.rst.1974-01-01_00000.nc
              firstfl=`/bin/ls ${basepath}/mpaso.rst.${cy}-01-01_00000.nc`
           else
              firstfl=`/bin/ls ${basepath}/${caseid}.h0.${cy}-01*.nc`
	   fi
       fi
   done
   
   #ncclimo 


   if  [[ $caseid == "mpas"* ]]; then
       /bin/ls $ncfiles | ncclimo --var=${varinp},timeMonthly_avg_daysSinceStartOfSim --job_nbr=$nvrs --yr_srt=$strtyr --yr_end=$stopyr --ypf=500 \
            --drc_out=${realpath}/${modnam} > ./ncclimo.lnd 2>&1
       ncrename -h -v timeMonthly_avg_daysSinceStartOfSim,Time ${realpath}/${modnam}/timeMonthly_avg_daysSinceStartOfSim_${strtyr}01_${stopyr}12.nc
       ncks -A -h ${realpath}/${modnam}/timeMonthly_avg_daysSinceStartOfSim_${strtyr}01_${stopyr}12.nc ${realpath}/${modnam}/${varinp}_${strtyr}01_${stopyr}12.nc
       ncrename -h -v Time,time ${realpath}/${modnam}/${varinp}_${strtyr}01_${stopyr}12.nc
       ncrename -h -d Time,time ${realpath}/${modnam}/${varinp}_${strtyr}01_${stopyr}12.nc
       ncatted -O -a units,time,o,c,"days since 1850-01-01 00:00:00" ${realpath}/${modnam}/${varinp}_${strtyr}01_${stopyr}12.nc
       ncatted -O -a calendar,time,o,c,"noleap" ${realpath}/${modnam}/${varinp}_${strtyr}01_${stopyr}12.nc
       echo 'bbb'
   else
       /bin/ls $ncfiles | ncclimo --var=${varinp} --job_nbr=$nvrs --yr_srt=$strtyr --yr_end=$stopyr --ypf=500 \
            --drc_out=${realpath}/${modnam} > ./ncclimo.lnd 2>&1
       echo 'aaa'
   fi

   #get the landfrac and area whatever cam or clm2

   #cam
   if  [[ $caseid == *"cam"* ]]; then

       if [[ $varinp == "SFCO2_OCN" ]]; then
          ncks -h -O -v OCNFRAC,area ${firstfl} -o temp_frac.nc
	  ncwa -O -h -a time temp_frac.nc ${realpath}/${modnam}/landfrac_area.nc
          #ncks -h -O -v OCNFRAC,area ${firstfl} -o ${realpath}/${modnam}/landfrac_area.nc
	  ncrename -h -O -v OCNFRAC,landfrac ${realpath}/${modnam}/landfrac_area.nc
	  /bin/rm -f temp_frac.nc
       else
          ncks -h -O -v LANDFRAC,area ${firstfl} -o temp_frac.nc
	  ncwa -O -h -a time temp_frac.nc ${realpath}/${modnam}/landfrac_area.nc
	  ncrename -h -O -v LANDFRAC,landfrac ${realpath}/${modnam}/landfrac_area.nc
	  /bin/rm -f temp_frac.nc
       fi
   fi

   #clm
   if  [[ $caseid == *"clm2"* ]]; then
       ncks -h -O -v landfrac,area ${firstfl} -o ${realpath}/${modnam}/landfrac_area.nc
   fi

   #mpas
   if  [[ $caseid == "mpas"* ]]; then

       #ncks -h -O -v areaCell ${firstfl} -o temp_area.nc
       #ncwa -O -h -a Time temp_area.nc ${realpath}/${modnam}/landfrac_area.nc
       ncks -h -O -v areaCell ${firstfl} -o ${realpath}/${modnam}/landfrac_area.nc
       ncrename -O -h -v areaCell,area ${realpath}/${modnam}/landfrac_area.nc
       #/bin/rm -f temp_area.nc
   fi

fi

for path in `ls $realpath`; do
    model=$path
    for var in "${chkvars[@]}"; do
        echo $var


	if [[ $itype != 'mip' ]]; then
           if [[ $model != $modnam ]]; then
	      echo "continue"
	      continue
	   fi
	fi


	   

    	xfil=(`ls $realpath/$model/${var}_*`)
    
    	if [ "${#xfil[@]}" -gt 1 ]; then
           echo "${xfil[*]}"
           temp=`basename ${xfil[0]}`
           file=${temp::-17}.nc
    	   ncrcat -h ${xfil[*]} -o $file   # potential bug
        elif [ "${#xfil[@]}" -eq 1 ]; then
           temp=`basename ${xfil[0]}`
           file=${temp::-17}.nc
           `pwd`
    	   /bin/cp -f ${xfil[0]} $file
    	else
           echo "cannot find the file for variable $var"
    	   continue
    	fi
    
    	name=`basename $file`
    	echo $file -- $name
    
        #GAAS - global average annual summary
    
        if [[ $itype == 'mip' ]]; then
           # get land frac and areacella
     
	   if [[ $name == *'Lmon'* ]]; then
              file_landfrac=`ls $realpath/$model/sftlf*.nc`
              file_areacell=`ls $realpath/$model/areacella*.nc`

	      compfrac=sftlf
    
	   elif [[ $name == *"Omon"* ]]; then
              file_landfrac=`ls $realpath/$model/sftof*.nc`
              file_areacell=`ls $realpath/$model/areacella*.nc`
	      compfrac=sftof
	   else
	      echo "error !!!!!"

	   fi
    
           echo $file_landfrac
           echo $file_areacell
    
           #kg/m2 * m2 *1.e-2*1.e-12 gsca=1.e-14
    
           if [[ -f $file_landfrac && -f $file_areacell ]]; then
    
              /bin/cp -f $file_landfrac tmp_$var.nc
              ncks -A $file_areacell tmp_$var.nc
              ncks -A $file tmp_$var.nc
    	      /bin/rm -f $file
    
    	      if [[ ${method:0:2} == "gs" ]]; then
                  wgtsum=${method:2:1}
                  if [[ $wgtsum == 1 ]]; then
                      ncap2 -O -v -s "${method}_${var}=($var*${compfrac}"'*0.01*areacella).sum($lat).sum($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtsum == 2 ]]; then
                      ncap2 -O -v -s "${method}_${var}=($var*"'areacella).sum($lat).sum($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                      ncap2 -O -v -s "${method}_${var}=$var"'.sum($lat).sum($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
    	      elif [[ ${method:0:2} == "ga" ]]; then
                  wgtavg=${method:2:1}
                  if [[ $wgtavg == 1 ]]; then
                      ncap2 -O -v -s "${method}_${var}=($var*"'sftlf*areacella).sum($lat).sum($lon)/((sftlf*areacella).sum($lat).sum($lon))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 2 ]]; then
                      ncap2 -O -v -s "${method}_${var}=($var*"'sftlf*areacella).avg($lat).avg($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                      ncap2 -O -v -s "${method}_${var}=$var"'.avg($lat).avg($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
    	      else
    	          echo "Invalid method for global operation $method"; exit -1;
    	      fi
           else
    	      ncwa -a lat,lon $file tmp_$var.nc  # global average
           fi

	   # temporal integration

            # annual operations
           if [[ ${method:3:2} == "aa" ]]; then
               #annual mean
                   #ncra -O --mro -d time,,,12,12 -w 31,28,31,30,31,30,31,31,30,31,30,31 tmp1_$var.nc -o tmp_$var.nc

               filelist=()
               for im in `seq 0 11`; do
                   ncflint --fix_rec_crd -h -O -d time,$im,,12 -w ${dpm[$im]},0.0 tmp1_$var.nc tmp1_$var.nc -o tmp${im}_tmp1_$var.nc
                   filelist+=(tmp${im}_tmp1_$var.nc)
               done

               #ncra -O --mro -d time,,,12,12 tmp1_$var.nc -o tmp_$var.nc
               nces -h -O ${filelist[*]} -o tmp_$var.nc
               ncap2 -O -v -s "${method}_${var}=${method}_${var}*12./365.*$asca+$afac" tmp_$var.nc GBL_${method}_${modnam}_${name}
               /bin/rm -f tmp*_tmp1_$var.nc
           elif [[ ${method:3:2} == "as" ]]; then
               #annual mean
                   #ncra -O --mro -d time,,,12,12 -w 31,28,31,30,31,30,31,31,30,31,30,31 tmp1_$var.nc -o tmp_$var.nc

               filelist=()
               for im in `seq 0 11`; do
                   ncflint --fix_rec_crd -h -O -d time,$im,,12 -w ${dpm[$im]},0.0 tmp1_$var.nc tmp1_$var.nc -o tmp${im}_tmp1_$var.nc
                   filelist+=(tmp${im}_tmp1_$var.nc)
               done

               # filelist contains multi-year files with different month, so the time record should be always same and it should be safe to use nces


               #-ncrcat -h -O ${filelist[*]} -o tmp1_$var.nc
               #-/bin/rm -f tmp*_tmp1_$var.nc
                   #-ncra -O --mro -d time,,,12,12 tmp1_$var.nc -o tmp_$var.nc
               nces -h -O ${filelist[*]} -o tmp_$var.nc
               ncap2 -O -v -s "${method}_${var}=${method}_${var}*12*$asca+$afac" tmp_$var.nc GBL_${method}_${modnam}_${name}
               /bin/rm -f tmp*_tmp1_$var.nc
           else
               echo "Invalid method for annual operation $method"; exit -1;
           fi
           /bin/rm -f tmp_$var.nc tmp1_$var.nc

        else  # raw model outputs
           #should be contained

           /bin/mv -f $file tmp_$var.nc

           if  [[ $caseid == "mpas"* ]]; then
              ncks -h -v area -A ${realpath}/${modnam}/landfrac_area.nc -o tmp_$var.nc
	   else
              ncks -h -v landfrac,area -A ${realpath}/${modnam}/landfrac_area.nc -o tmp_$var.nc
	   fi

           dmnlst=`ncdmnlst tmp_$var.nc`

    	   if [[ ${method:0:2} == "gs" ]]; then

              wgtsum=${method:2:1}
              if [[ $dmnlst == *"lat"* ]]; then
                  if [[ $wgtsum == 1 ]]; then  # land area sum
                      ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($lat).sum($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtsum == 2 ]]; then # grid area sum
                      echo "all area"
                      ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($lat).sum($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else  # var sum
                      ncap2 -O -v -s "${method}_${var}=$var"'.sum($lat).sum($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
              elif [[ $dmnlst == *"lndgrid"* ]]; then
                  if [[ $wgtsum == 1 ]]; then
                      ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($lndgrid)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtsum == 2 ]]; then
                      echo "all area"
                      ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($lndgrid)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                      ncap2 -O -v -s "${method}_${var}=$var"'.sum($lndgrid)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi

              elif [[ $dmnlst == *"ncol"* ]]; then
                  if [[ $wgtsum == 1 ]]; then
		      ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($ncol)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtsum == 2 ]]; then
                      echo "all area"
                      ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($ncol)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                      ncap2 -O -v -s "${method}_${var}=$var"'.sum($ncol)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
              elif [[ $dmnlst == *"nCells"* ]]; then
                  if [[ $wgtsum == 1 ]]; then
                      ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($nCells)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtsum == 2 ]]; then
                      echo "all area"
                      ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($nCells)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                      ncap2 -O -v -s "${method}_${var}=$var"'.sum($nCells)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
              fi
          
           # Global average
           wgtavg=${method:2:1}
    	   elif [[ ${method:0:2} == "ga" ]]; then

              if [[ $dmnlst == *"lat"* ]]; then
                  if [[ $wgtavg == 1 ]]; then  # land area weighted averaged
                      ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($lat).sum($lon)/((landfrac*area).sum($lat).sum($lon))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 2 ]]; then  # land area weighted averaged
                      ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($lat).sum($lon)/((area).sum($lat).sum($lon))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 3 ]]; then # land area sum averaged
                      ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).avg($lat).avg($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else # var averaged
                      ncap2 -O -v -s "${method}_${var}=$var"'.avg($lat).avg($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
              elif [[ $dmnlst == *"lndgrid"* ]]; then
                  if [[ $wgtavg == 1 ]]; then
                     ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($lndgrid)/((landfrac*area).sum($lndgrid))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 2 ]]; then
                     ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($lndgrid)/((area).sum($lndgrid))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 3 ]]; then
                     ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).avg($lndgrid)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                     ncap2 -O -v -s "${method}_${var}=$var"'.avg($lndgrid)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
              elif [[ $dmnlst == *"ncol"* ]]; then
                  if [[ $wgtavg == 1 ]]; then
                     ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($ncol)/((landfrac*area).sum($ncol))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 2 ]]; then
                     ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($ncol)/((area).sum($ncol))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 3 ]]; then  # land area 
                     ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).avg($ncol)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                     ncap2 -O -v -s "${method}_${var}=$var"'.avg($ncol)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
              elif [[ $dmnlst == *"nCells"* ]]; then
                  if [[ $wgtavg == 1 ]]; then
                     ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).sum($nCells)/((landfrac*area).sum($nCells))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 2 ]]; then
                     ncap2 -O -v -s "${method}_${var}=($var*"'area).sum($nCells)/((area).sum($nCells))*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  elif [[ $wgtavg == 3 ]]; then  # land area 
                     ncap2 -O -v -s "${method}_${var}=($var*"'landfrac*area).avg($nCells)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  else
                     ncap2 -O -v -s "${method}_${var}=$var"'.avg($nCells)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
                  fi
              fi
    	   else
    	       echo "Invalid method for global operation $method"; exit -1;
    	   fi

            # annual operations
    	   if [[ ${method:3:2} == "aa" ]]; then
    	       #annual mean
                   #ncra -O --mro -d time,,,12,12 -w 31,28,31,30,31,30,31,31,30,31,30,31 tmp1_$var.nc -o tmp_$var.nc
    
    	       filelist=()
    	       for im in `seq 0 11`; do
    	           ncflint --fix_rec_crd -h -O -d time,$im,,12 -w ${dpm[$im]},0.0 tmp1_$var.nc tmp1_$var.nc -o tmp${im}_tmp1_$var.nc
    	           filelist+=(tmp${im}_tmp1_$var.nc)
               done
    
               #ncra -O --mro -d time,,,12,12 tmp1_$var.nc -o tmp_$var.nc
    	       nces -h -O ${filelist[*]} -o tmp_$var.nc
    	       ncap2 -O -v -s "${method}_${var}=${method}_${var}*12./365.*$asca+$afac" tmp_$var.nc GBL_${method}_${modnam}_${name}
    	       /bin/rm -f tmp*_tmp1_$var.nc
           elif [[ ${method:3:2} == "as" ]]; then
    	       #annual mean
                   #ncra -O --mro -d time,,,12,12 -w 31,28,31,30,31,30,31,31,30,31,30,31 tmp1_$var.nc -o tmp_$var.nc
    
    	       filelist=()
    	       for im in `seq 0 11`; do
    	           ncflint --fix_rec_crd -h -O -d time,$im,,12 -w ${dpm[$im]},0.0 tmp1_$var.nc tmp1_$var.nc -o tmp${im}_tmp1_$var.nc
    	           filelist+=(tmp${im}_tmp1_$var.nc)
               done
    
    	       # filelist contains multi-year files with different month, so the time record should be always same and it should be safe to use nces
    
    
    	       #-ncrcat -h -O ${filelist[*]} -o tmp1_$var.nc
    	       #-/bin/rm -f tmp*_tmp1_$var.nc
                   #-ncra -O --mro -d time,,,12,12 tmp1_$var.nc -o tmp_$var.nc
    	       nces -h -O ${filelist[*]} -o tmp_$var.nc
               ncap2 -O -v -s "${method}_${var}=${method}_${var}*12*$asca+$afac" tmp_$var.nc GBL_${method}_${modnam}_${name}
    	       /bin/rm -f tmp*_tmp1_$var.nc
    	   else
    	       echo "Invalid method for annual operation $method"; exit -1;
    	   fi
    	   /bin/rm -f tmp_$var.nc tmp1_$var.nc
        fi
    done
done


exit
# now ploting figures:
module rm python
module load python3/3.7-anaconda-2019.07
for var in "${chkvars[@]}"; do
    python plot_global_time_series.py *${method}_$var*.nc 
done
