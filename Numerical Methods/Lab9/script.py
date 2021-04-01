import numpy as np
import matplotlib.pyplot as plt

files = ["g1N11",
         "g1N51",
         "g1N21",
         "g1N101"]


N = [11,
     21,
     51,
     101]


ax = plt.gca()

for n in N:
    plt.title(f"N = {n}")
    data = np.loadtxt("g1N"+str(n)+".txt")
    plt.plot(data[:, 0], data[:, 1], label="g(x)")
    plt.plot(data[:, 0], data[:, 2], label="G(x)")
    plt.legend(loc = 'upper right')
    plt.xlabel("x")
    plt.ylabel("y")
    plt.grid()
    plt.savefig("g1N"+str(n)+".png")
    ax.cla()


for n in N:
    name = "g2N"+str(n)
    plt.title(f"N = {n}")
    data = np.loadtxt(name+".txt")
    dataAppr = np.loadtxt(name+"Appr.txt")
    plt.scatter(data[:, 0], data[:, 1], label=r"$g_{2}(x)$", color="tab:olive")
    plt.plot(dataAppr[:, 0], dataAppr[:, 1], label=r"$G_{2}(x)$")
    plt.legend(loc = 'upper right')
    plt.xlabel("x")
    plt.ylabel("y")
    plt.grid()
    plt.savefig("g2N"+str(n)+".png")
    ax.cla()

