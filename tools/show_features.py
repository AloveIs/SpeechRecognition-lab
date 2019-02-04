#!/usr/bin/env python
import os
import sys
import tempfile
import numpy as np
from matplotlib import pyplot as plt

# hardcoded!
samplingfreq = 16000

configFile = sys.argv[1]
inputFile = sys.argv[2]

# first extract sound samples
wavConfFile, wavConfFileName = tempfile.mkstemp()
os.write(wavConfFile, 'SOURCEKIND = WAVEFORM\nSOURCEFORMAT = WAV\n')
command = 'HList -r -C '+wavConfFileName+' '+inputFile
rawdata = os.popen(command).read()
os.close(wavConfFile)
wavdata = np.fromstring(rawdata, sep=' ')

# then extract features
command = 'HList -r -C '+configFile+' '+inputFile
rawdata = os.popen(command).read()
nlines = len(rawdata.splitlines())
data = np.fromstring(rawdata, sep=' ')
ncols = len(data)/nlines
feats = np.reshape(data, (nlines, ncols))

plt.figure(1)
plt.subplot(211)
timescale = np.arange(len(wavdata), dtype=float)/samplingfreq
plt.plot(timescale, wavdata)
plt.xlabel('time (sec)')
plt.ylabel('amplitude')
plt.xlim(timescale[0], timescale[-1])
plt.title('audio samples')

plt.subplot(212)
plt.matshow(feats.T, fignum=False)
plt.gca().invert_yaxis()
plt.title('features')
plt.show()
