#!/usr/bin/env bash


#set -x
module load nco

chkvars=(cLitter cSoilFast cSoilMedium cSoilSlow)
chkvars=(cLitter)
basepath=/global/cscratch1/sd/minxu/CMIP6_ILAMB/LS3MIP_MODEL/


gsca=1.0; asca=1.0
gfac=0.0; afac=0.0

OPTIONS=v:m:
LNGOPTS=variable:,method:,Gscale:,Ascale:,Gfactor:,Afactor:

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
exit

echo $varinp $method

IFS=',' read -r -a chkvars <<< "$varinp"


for path in `ls $basepath`; do
    model=$path
    for var in "${chkvars[@]}"; do
	echo $var
	file=`ls $basepath/$model/${var}_*`
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

           /bin/cp -f $file_landfrac tmp.nc
           ncks -A $file_areacell tmp.nc
           ncks -A $file tmp.nc

	   if [[ $method == "gsas" ]]; then
               ncap2 -O -v -s "${method}_${var}=($var*sftlf*"'areacella).sum($lat).sum($lon)*'"$gsca+$gfac" tmp.nc -o tmp1.nc
	       #annual mean
               ncra -O --mro -d time,,,12,12 tmp1.nc -o tmp.nc
               ncap2 -O -v -s "${method}_${var}=${method}_${var}*12*$asca+$afac" tmp.nc GBL_${method}_$name
	       /bin/rm -f tmp.nc tmp1.nc
	   fi

	   if [[ $method == "gsaa" ]]; then  #state
               ncap2 -O -v -s "${method}_${var}=($var*sftlf*"'areacella).sum($lat).sum($lon)*'"$gsca+$gfac" tmp.nc -o tmp1.nc
	       #annual mean
               ncra -O --mro -d time,,,12,12 tmp1.nc -o tmp.nc
	       ncap2 -O -v -s "${method}_${var}=${method}_${var}*$asca+$afac" tmp.nc GBL_${method}_$name
	       /bin/rm -f tmp.nc tmp1.nc
	   fi

	   if [[ $method == "gaas" ]]; then
               ncap2 -O -v -s "${method}_${var}=($var*sftlf*"'areacella).avg($lat).avg($lon)*'"$gsca+$gfac" tmp.nc -o tmp1.nc
	       #annual mean
               ncra -O --mro -d time,,,12,12 tmp1.nc -o tmp.nc
               ncap2 -O -v -s "${method}_${var}=${method}_${var}*12*$asca+$afac" tmp.nc GBL_${method}_$name
	       /bin/rm -f tmp.nc tmp1.nc
	   fi

	   if [[ $method == "gaaa" ]]; then  
               ncap2 -O -v -s "${method}_${var}=($var*sftlf*"'areacella).avg($lat).avg($lon)*'"$gsca+$gfac" tmp.nc -o tmp1.nc
	       #annual mean
               ncra -O --mro -d time,,,12,12 tmp1.nc -o tmp.nc
	       ncap2 -O -v -s "${method}_${var}=${method}_${var}*$asca+$afac" tmp.nc GBL_${method}_$name
	       /bin/rm -f tmp.nc tmp1.nc
	   fi

        else
	   ncwa -a lat,lon $file tmp.nc  # global average
           ncra -O --mro -d time,,,12,12 tmp.nc GBL_uwgt_$name
	   ncrename -v $var,uwgt_${var} GBL_uwgt_$name
        fi
    done
done
