#!/usr/bin/env bash

module load nco

#units: mmols/m2/s 1.e-3 * 12 * 1.e-15 Pg = 1.2e-17

#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/global_time_series/1pctco2/ -v gpp \
#       -m gs1as --Gscale=1.e-12 --Ascale=86400.0 --itype=mip

./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/global_time_series/1pctco2/ -v fgco2 \
       -m gs1as --Gscale=1.e-12 --Ascale=86400.0 --itype=mip

#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/global_time_series/1pctco2/ -v soilc \
#       -m gs1aa --Gscale=1.e-12 --Ascale=1. --itype=mip
#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/processed/src/global_time_series/1pctco2/ -v tas \
#       -m ga1aa --Gscale=1. --Ascale=1. --itype=mip
