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
   #varn = '_'.join(temp[1:2]) + '_'+temp[-1][:-3]
   #varn = temp[1]+'_'+temp[3]

   if 'CO2' in file:
      varn = temp[1]+'_'+'_'.join(temp[4:8])+ '_' + temp[-1][:-3]
   else:
      varn = temp[1]+'_'+temp[3]

   #varn = temp[1]+'_'+temp[4][:-3]
   #models.append(temp[3])

   print (varn)



   with nc4.Dataset(file, "r") as fnc:
        #fildate = nc4.num2date(fnc.variables['time'][:], units=fnc.variables['time'].units, calendar='noleap')
        #fildate = cftime.num2date(fnc.variables['time'][:], units=fnc.variables['time'].units, only_use_cftime_datetimes=False)
        #fildate = cftime.num2pydate(fnc.variables['time'][:], units=fnc.variables['time'].units, calendar='noleap')
        fildate = cftime.num2date(fnc.variables['time'][:], units=fnc.variables['time'].units, calendar='noleap', only_use_cftime_datetimes=False)

        #-print (fildate)

        #-print (type(fildate))

        mpldate=[]
        for fd in fildate:
            pd = datetime.datetime(fd.year, fd.month, fd.day)

            print (pd)
            mpldate.append(mpl.dates.date2num(pd))
        #mpldate = nc4.date2num(fildate[:], calendar='noleap')

        #varvals = fnc.variables[varnr][:]
        varvals = fnc.variables[varn][:]

        xx = np.arange(150)


        #ploting
        #axarr[0].plot_date(mpldate, varvals, '-', label='', linewidth=1.)
        if 'CO2' in file:
           axarr[0].plot(xx, varvals, '-', label='', linewidth=1.)
        else:
           varvals = fnc.variables[varn][:] * (-12./44.)
           axarr[0].plot(xx, varvals, '--', label='', linewidth=2.)
        #axarr[0].legend(bbox_to_anchor=(0.3, 0.9), loc='upper left', borderaxespad=0.)


        varvals = np.cumsum(fnc.variables[varn][:])
        #ploting
        #axarr[1].plot_date(mpldate, varvals, '-', label=temp[3], linewidth=1.)

        if 'CO2' in file:
            axarr[1].plot(xx, varvals, '-', label=temp[3]+temp[4][:-3], linewidth=1.)
        else:
            varvals = np.cumsum(fnc.variables[varn][:]) * (-12./44.)
            axarr[1].plot(xx, varvals, '--', label=temp[3]+temp[4][:-3], linewidth=2.)
        axarr[1].legend(bbox_to_anchor=(0.3, 0.9), loc='upper left', borderaxespad=0.)



axarr[0].set(xlabel='time (Yr)', ylabel=temp[2], 
        title=temp[3]+"  units: PgC")
plt.savefig("newfig_" + "_".join(temp[0:]) + ".ps")

