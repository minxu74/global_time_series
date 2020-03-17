#!/usr/bin/env python


import netCDF4 as nc4

import matplotlib as mpl
import matplotlib.pyplot as plt

import datetime
import numpy as np


import sys, cftime


if len(sys.argv) < 2:
   print ("Please provide the file names")
else:
   print (len(sys.argv))


f, axarr = plt.subplots(2, sharex=True)

models=[]
for file in sys.argv[1:]:
   print (file.split('_'))

   temp = file.split('_')

   #varn = temp[1]+'_'+temp[2][:-3]
   #varn = '_'.join(temp[1:-1]) + '_'+temp[-1][:-3]
   varn = '_'.join(temp[1:2]) + '_'+temp[-1][:-3]
   #models.append(temp[3])


   with nc4.Dataset(file, "r") as fnc:
        #fildate = nc4.num2date(fnc.variables['time'][:], units=fnc.variables['time'].units, calendar='noleap')
        fildate = cftime.num2date(fnc.variables['time'][:], units=fnc.variables['time'].units, only_use_cftime_datetimes=False)

        #-print (fildate)

        #-print (type(fildate))
        mpldate = mpl.dates.date2num(fildate[:])

        varvals = fnc.variables[varn][:]
        #ploting
        axarr[0].plot_date(mpldate, varvals, '-', label='E3SM', linewidth=2.)
        axarr[0].legend(bbox_to_anchor=(0.3, 0.9), loc='upper left', borderaxespad=0.)


        varvals = np.cumsum(fnc.variables[varn][:])
        #ploting
        axarr[1].plot_date(mpldate, varvals, '-', label='E3SM', linewidth=2.)
        axarr[1].legend(bbox_to_anchor=(0.3, 0.9), loc='upper left', borderaxespad=0.)



axarr[0].set(xlabel='time (Yr)', ylabel=temp[2], 
        title='_'.join(temp[0:])+"units: PgC")
plt.savefig("fig_" + "_".join(temp[0:]) + ".ps")






