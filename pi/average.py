import glob
import numpy as np

data = []
for filename in glob.glob('result*.dat'):
  with open(filename) as f:
    a = f.readlines()[0]
    data.append(float(a))

average = np.average(data)
error = np.std(data)

print(f"{average} +- {error}")
