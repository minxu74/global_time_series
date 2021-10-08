#!/usr/bin/env bash


bgnyear=1976
endyear=2005
lcaseid=20200509.CO21PCTCTL_RUBISCO_CNCTC1850_OIBGC.ne30_oECv3.compy.clm2.h0
acaseid=20200509.CO21PCTCTL_RUBISCO_CNCTC1850_OIBGC.ne30_oECv3.compy.cam.h0
ocaseid=mpaso.hist.am.timeSeriesStatsMonthly
mod_nam=E3SM_1PCTCO2CTL_CN

#for land
./comp_global_time_series.sh -v NEE   -m gs1as --Gscale=-1.e-9    --Ascale=86400. --modnam=$mod_nam --caseid=$lcaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
