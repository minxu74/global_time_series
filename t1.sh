#!/usr/bin/env bash


bgnyear=1850
endyear=2005
lcaseid=20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy.clm2.h0
acaseid=20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy.cam.h0
ocaseid=mpaso.hist.am.timeSeriesStatsMonthly
mod_nam=E3SM_1PCTCO2CTL


#for land
#./aaa.sh -v NEE   -m gs1as --Gscale=-1.e-9    --Ascale=86400. --modnam=$mod_nam --caseid=$lcaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw


./aaa.sh -v SFCO2 -m gs2as --Gscale=39.904489 --Ascale=86400. --modnam=$mod_nam --caseid=$acaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
#-
#-
#-#for ocean
./aaa.sh -v timeMonthly_avg_atmosphericCO2                          -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./aaa.sh -v timeMonthly_avg_atmosphericCO2_ALT_CO2                  -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw


