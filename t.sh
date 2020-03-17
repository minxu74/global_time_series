#!/usr/bin/env bash

module load nco

#units: mmols/m2/s 1.e-3 * 12 * 1.e-15 Pg = 1.2e-17
#-./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v timeMonthly_avg_CO2_gas_flux \
#-       -m gs2as --Gscale=1.2e-17 --Ascale=86400.0 --modnam=E3SM_1PCTCO2 --caseid=mpaso.hist.am.timeSeriesStatsMonthly \
#-       --strtyr=1900 --stopyr=2049 --itype=raw

# earth radius 6.37122e6, its squre 40.5924442884e12 = 4.05924442884e13, units is kg CO2/m2/s -> kg->1.e-12Pg, CO2 to C 12/44. = 40.5924442884*12/44.=11.070666624109093
#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v SFCO2_OCN \
#       -m gs1as --Gscale=11.070666624109093 --Ascale=86400.0 --modnam=E3SM_1PCTCO2 --caseid=20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy.cam \
#       --strtyr=1900 --stopyr=2049 --itype=raw

# not use ocean fraction
#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v SFCO2_OCN \
#       -m gs2as --Gscale=11.070666624109093 --Ascale=86400.0 --modnam=E3SM_1PCTCO2 --caseid=20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy.cam \
#       --strtyr=1900 --stopyr=2049 --itype=raw

#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v SFCO2_LND \
#       -m gs1as --Gscale=11.070666624109093 --Ascale=86400.0 --modnam=E3SM_1PCTCO2 --caseid=20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy.cam \
#       --strtyr=1900 --stopyr=2049 --itype=raw

#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v TREFHT \
#       -m ga2aa --Gscale=1. --Ascale=1. --modnam=E3SM_1PCTCO2 --caseid=20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy.cam \
#       --strtyr=1900 --stopyr=2049 --itype=raw

#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v SFCO2_OCN \
#       -m gs2as --Gscale=11.070666624109093 --Ascale=86400.0 --modnam=E3SM_1PCTCO2 --caseid=20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy.cam \
#       --strtyr=1900 --stopyr=2049 --itype=raw

#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v NEE \
#       -m gs1as --Gscale=1.e-9 --Ascale=86400.0 --modnam=E3SM_1PCTCO2 --caseid=20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy.clm2 \
#       --strtyr=1900 --stopyr=2049 --itype=raw

./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy/run -v NBP \
       -m gs1as --Gscale=1.e-9 --Ascale=86400.0 --modnam=E3SM_1PCTCO2FUL --caseid=20191123.CO21PCTFUL_RUBISCO_CNPCTC20TR_OIBGC.I1900.ne30_oECv3.compy.clm2 \
       --strtyr=1900 --stopyr=2049 --itype=raw
#
#./comp_global_time_series.sh -b /global/cfs/cdirs/m3522/1pctco2_temp/20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy/run -v NBP \
#       -m gs1as --Gscale=1.e-9 --Ascale=86400.0 --modnam=E3SM_1PCTCO2CTL --caseid=20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy.clm2 \
#       --strtyr=1900 --stopyr=2049 --itype=raw
#
#./comp_global_time_series.sh -b /global/cfs/projectdirs/m3522/cmip6/1pctCO2-E3SM/20191020.CO21PCTBGC_RUBISCO_CNPCTC20TR_OIBGC.ne30_oECv3.compy/run -v NBP \
#       -m gs1as --Gscale=1.e-9 --Ascale=86400.0 --modnam=E3SM_1PCTCO2 --caseid=20191020.CO21PCTBGC_RUBISCO_CNPCTC20TR_OIBGC.ne30_oECv3.compy.clm2 \
#       --strtyr=1850 --stopyr=2000 --itype=raw
