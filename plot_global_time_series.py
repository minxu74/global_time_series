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


fig = plt.figure()
ax = fig.add_axes([0.1, 0.1, 0.85, 0.85])


models=[]
for file in sys.argv[1:]:
   print (file.split('_'))

   temp = file.split('_')

   varn = temp[1]+'_'+temp[2]
   models.append(temp[3])


   with nc4.Dataset(file, "r") as fnc:
        #fildate = nc4.num2date(fnc.variables['time'][:], units=fnc.variables['time'].units, calendar='noleap')
        fildate = cftime.num2date(fnc.variables['time'][:], units=fnc.variables['time'].units, only_use_cftime_datetimes=False)

        #-print (fildate)

        #-print (type(fildate))
        mpldate = mpl.dates.date2num(fildate[0::12])
        varvals = fnc.variables[varn][0::12]

        #ploting
        ax.plot_date(mpldate, varvals, '-', label=temp[4], linewidth=2.)
        ax.legend(bbox_to_anchor=(0.3, 0.9), loc='upper left', borderaxespad=0.)


ax.set(xlabel='time (Yr)', ylabel=temp[2], 
        title='_'.join(temp[0:4]))
plt.savefig("fig_" + "_".join(temp[0:3]) + ".ps")






