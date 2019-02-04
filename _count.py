import numpy as np


d = np.loadtxt("count.txt", delimiter="\n")

print(d)

print("Avg:" + str(np.mean(d))+ "\nSamples:" + str(np.mean(d)/0.025))

