import numpy as np
import matplotlib.pyplot as plt

filesF1 =["f1n5",
	      "f1n6",
	      "f1n10",
	      "f1n20"]

filesF2 = ["f2n6",
	       "f2n7",
	       "f2n14"]

n = [5, 6, 10, 20]

ax = plt.gca()

for file, n_val in zip(filesF1, n):
	data = np.loadtxt(file+".txt")
	dataNode = np.loadtxt(file+"nodes.txt")
	plt.plot(data[:, 0], data[:, 1], label="n = %s" %(n_val))
	plt.plot(data[:, 0], data[:, 2])
	plt.scatter(dataNode[:, 0], dataNode[:, 1])
	plt.legend(loc = 'upper right')
	plt.xlabel("x")
	plt.ylabel("y")
	plt.grid()
	plt.savefig(file+".png")
	ax.cla()


n = [6, 7, 14]
for file, n_val in zip(filesF2, n):
	data = np.loadtxt(file+".txt")
	dataNode = np.loadtxt(file+"nodes.txt")
	plt.plot(data[:, 0], data[:, 1], label="n = %s" %(n_val))
	plt.plot(data[:, 0], data[:, 2])
	plt.scatter(dataNode[:, 0], dataNode[:, 1])
	plt.legend(loc = 'upper right')
	plt.xlabel("x")
	plt.ylabel("y")
	plt.grid()
	plt.savefig(file+".png")
	ax.cla()


