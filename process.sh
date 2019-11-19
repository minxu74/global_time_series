#!/usr/bin/env bash


# fraction x fraction [1.e-4] m2 - km2 [1.e-6] million [1.e-6] so total 1.e-16

# - get the fractions
./comp_global_time_series.sh -v baresoilFrac,c3PftFrac,c4PftFrac,grassFrac,shrubFrac -m gaaa --wgtavg=1 & #--Gscale=1.e-16 &
./comp_global_time_series.sh -v burntFractionAll,residualFrac                        -m gaaa --wgtavg=1 & #--Gscale=1.e-16 &

#landCoverFrac is not calcualted as different models have different landtype




# C state kg/m2  1.e-2 x 1.e-12
#./comp_global_time_series.sh -v cLitter,cSoilFast,cSoilMedium,cSoilSlow -m gsaa --Gscale=1.e-14  &
#./comp_global_time_series.sh -v cRoot,cVeg,cCwd,cLeaf                   -m gsaa --Gscale=1.e-14  &


# fluxes kg/m2/s
#./comp_global_time_series.sh -v evspsblsoi,evspsblveg,tran,prveg  -m gsas --Gscale=1.0e-14 --Ascale=86400.
#

#-mrfso
#-mrro
#./comp_global_time_series.sh -v mrros -m gsas --Gscale=1.e-14 --Ascale=86400.
#-mrso

#kg /m2
#./comp_global_time_series.sh -v mrsos -m gsaa --Gscale=1.e-14
#-tsl
#-landCoverFrac


# carbon flux
#./comp_global_time_series.sh -v fHarvest,fLitterSoil,fVegLitter     -m gsas --Gscale=1.e-14 --Ascale=86400. &
#kg/m2/s  Gscale=1.e-2i[%-fraction]*1.e-12[kg-Pg]  Ascale=30*86400.=2592000
#./comp_global_time_series.sh -v gpp,nbp,nppLeaf,nppRoot,nppWood,npp -m gsas --Gscale=1.e-14 --Ascale=86400. &
#./comp_global_time_series.sh -v rGrowth,rMaint,ra,rh                -m gsas --Gscale=1.e-14 --Ascale=86400. &
#./comp_global_time_series.sh -v lai                                 -m gaaa &
