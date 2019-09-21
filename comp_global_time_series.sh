#!/usr/bin/env bash


set -x
module load nco

chkvars=(cLitter cSoilFast cSoilMedium cSoilSlow)
chkvars=(cLitter)
basepath=/global/cscratch1/sd/minxu/CMIP6_ILAMB/LS3MIP_MODEL/

dpm=(31 28 31 30 31 30 31 31 30 31 30 31)

gsca=1.0; asca=1.0
gfac=0.0; afac=0.0

OPTIONS=hv:m:
LNGOPTS=help,variable:,method:,Gscale:,Ascale:,Gfactor:,Afactor:

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
            echo "`basename $0` -h[--help] -v[--variable] -m[--method] [--Gsacle] [--Ascale] [--Gfactor] [ --Afactor]"
            shift 1
	    exit
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


function isFloat() {
   if [[ "$1" =~ ^-?[0-9]*[.,]?[0-9]*[eE]-?[0-9]+$ || "$1" =~ ^-?[0-9]*[.,]?[0-9]*$ ||  "$1" =~ ^-?[0-9]+$ ]]; then
      echo 0
   else
      echo 1
   fi
}

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


for path in `ls $basepath`; do
    model=$path
    for var in "${chkvars[@]}"; do
	echo $var
	xfil=(`ls $basepath/$model/${var}_*`)

	if [ "${#xfil[@]}" -gt 1 ]; then
           echo "${xfil[*]}"
           temp=`basename ${xfil[0]}`
           file=${temp::-17}.nc
	   ncrcat -h ${xfil[*]} -o $file
	   echo "1111"
        elif [ "${#xfil[@]}" -eq 1 ]; then
           temp=`basename ${xfil[0]}`
           file=${temp::-17}.nc
	   /bin/cp -f ${xfil[0]} $file
	else
           echo "cannot find the file for variable $var"
	   continue
	fi

	name=`basename $file`
	echo $file -- $name

        #GAAS - global average annual summary

        # get land frac and areacella
 
        file_landfrac=`ls $basepath/$model/sftlf*.nc`
        file_areacell=`ls $basepath/$model/areacella*.nc`


        echo $file_landfrac
        echo $file_areacell


        #kg/m2 * m2 *1.e-2*1.e-12 gsca=1.e-14

        if [[ -f $file_landfrac && -f $file_areacell ]]; then

           /bin/cp -f $file_landfrac tmp_$var.nc
           ncks -A $file_areacell tmp_$var.nc
           ncks -A $file tmp_$var.nc
	   /bin/rm -f $file

	   if [[ ${method:0:2} == "gs" ]]; then
               ncap2 -O -v -s "${method}_${var}=($var*sftlf*"'areacella).sum($lat).sum($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
	   elif [[ ${method:0:2} == "ga" ]]; then
               ncap2 -O -v -s "${method}_${var}=($var*sftlf*"'areacella).avg($lat).avg($lon)*'"$gsca+$gfac" tmp_$var.nc -o tmp1_$var.nc
	   else
	       echo "Invalid method for global operation $method"; exit -1;
	   fi

	   if [[ ${method:2:2} == "aa" ]]; then
	       #annual mean
               #ncra -O --mro -d time,,,12,12 -w 31,28,31,30,31,30,31,31,30,31,30,31 tmp1_$var.nc -o tmp_$var.nc
               ncra -O --mro -d time,,,12,12 tmp1_$var.nc -o tmp_$var.nc
	       ncap2 -O -v -s "${method}_${var}=${method}_${var}*$asca+$afac" tmp_$var.nc GBL_${method}_$name
           elif [[ ${method:2:2} == "as" ]]; then
	       #annual mean
               #ncra -O --mro -d time,,,12,12 -w 31,28,31,30,31,30,31,31,30,31,30,31 tmp1_$var.nc -o tmp_$var.nc

	       #-filelist=()
	       #-for im in `seq 0 11`; do
	       #-    ncflint --fix_rec_crd -h -O -d time,$im,,12 -w ${dpm[$im]},0.0 tmp1_$var.nc tmp1_$var.nc -o tmp${im}_tmp1_$var.nc
	       #-    filelist+=(tmp${im}_tmp1_$var.nc)
               #-done

	       #-ncrcat -h -O ${filelist[*]} -o tmp1_$var.nc
	       #-exit;
	       #-/bin/rm -f tmp*_tmp1_$var.nc

               ncra -O --mro -d time,,,12,12 tmp1_$var.nc -o tmp_$var.nc
               ncap2 -O -v -s "${method}_${var}=${method}_${var}*12*$asca+$afac" tmp_$var.nc GBL_${method}_$name
	   else
	       echo "Invalid method for annual operation $method"; exit -1;
	   fi

	   /bin/rm -f tmp_$var.nc tmp1_$var.nc


        else
	   ncwa -a lat,lon $file tmp_$var.nc  # global average
           ncra -O --mro -d time,,,12,12 tmp_$var.nc GBL_uwgt_$name
	   ncrename -v $var,uwgt_${var} GBL_uwgt_$name
        fi
    done
done


# now ploting figures:
module rm python
module load python3/3.7-anaconda-2019.07
for var in "${chkvars[@]}"; do
    python plot_global_time_series.py *${method}_$var*.nc
done

