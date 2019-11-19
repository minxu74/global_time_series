#!/usr/bin/env bash


bgnyear=1850
endyear=1904
lcaseid=20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy.clm2.h0
acaseid=20191020.CO21PCTCTL_RUBISCO_CNPCTC1850_OIBGC.ne30_oECv3.compy.cam.h0
ocaseid=mpaso.hist.am.timeSeriesStatsMonthly
mod_nam=E3SM_1PCTCO2CTL


#for land
#./comp_global_time_series.sh -v NEE   -m gs1as --Gscale=-1.e-9    --Ascale=86400. --modnam=$mod_nam --caseid=$lcaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
#kg/m2/s * (1.e6 m2 6317*6317)sr2 * fraction * 1.e-12 = 39904489e-6
#./comp_global_time_series.sh -v SFCO2 -m gs2as --Gscale=39.904489 --Ascale=86400. --modnam=$mod_nam --caseid=$acaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
#-
#-
#-#for ocean
./comp_global_time_series.sh -v timeMonthly_avg_atmosphericCO2                          -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./comp_global_time_series.sh -v timeMonthly_avg_atmosphericCO2_ALT_CO2                  -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./comp_global_time_series.sh -v timeMonthly_avg_CO2_gas_flux                            -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./comp_global_time_series.sh -v timeMonthly_avg_CO2_alt_gas_flux                        -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./comp_global_time_series.sh -v timeMonthly_avg_ecosys_diag_pCO2surface_ALT_CO2         -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./comp_global_time_series.sh -v timeMonthly_avg_ecosys_diag_pCO2surface         -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./comp_global_time_series.sh -v timeMonthly_avg_ecosysTracersSurfaceFlux_DICSurfaceFlux -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
./comp_global_time_series.sh -v timeMonthly_avg_ecosysTracersSurfaceFlux_DIC_ALT_CO2SurfaceFlux -m ga2aa --Gscale=1. --Ascale=1. --modnam=$mod_nam --caseid=$ocaseid --strtyr=$bgnyear --stopyr=$endyear --itype=raw
