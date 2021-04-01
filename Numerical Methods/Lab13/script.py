import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots()

filename = "c2her"
data = np.loadtxt(filename + ".txt")
filename2 = "c2leg"
data2 = np.loadtxt(filename2 + ".txt")
ax.plot(data[:, 0], data[:, 1], marker="o", ls="", label=f"Gaussa-Hermite'a")
ax.plot(data2[:, 0], data2[:, 1], marker="o", ls="", label=f"Gaussa-Legendre'a")
ax.autoscale(enable=True, axis="y", tight=False)
plt.title(r"$ln(x)e^{-x^2}$")
ax.yaxis.set_ticks(np.arange(0,1.1,0.1))
plt.legend()
plt.xlabel(r"n")
plt.ylabel(r"$|c_2-c_{2,a}|$")

plt.grid()
plt.savefig(filename + ".png")
ax.cla()

filename = "c1"
data = np.loadtxt(filename + ".txt")
ax.plot(data[:, 0], data[:, 1], marker="o", ls="", label="Gaussa-Legendre'a")
plt.title(r"$\frac{1}{x\sqrt{x^{2} -1}}$")
plt.legend()
plt.xlabel(r"n")
plt.ylabel(r"$|c_1-c_{1,a}|$")
plt.grid()
plt.savefig(filename + ".png")
ax.cla()

filename = "c3lag"
data = np.loadtxt(filename + ".txt")
ax.plot(data[:, 0], data[:, 1], marker="o", ls="", label="Gaussa-Laugere'a")
plt.legend()
plt.title(r"$sin(2x)e^{-3x}$")
ax.yaxis.set_ticks(np.arange(0,.11,0.01))
plt.xlabel(r"n")
plt.ylabel(r"$|c_3-c_{3,a}|$")
plt.grid()
plt.savefig(filename + ".png")
ax.cla()

filename = "f2plot"
data = np.loadtxt(filename + ".txt")
ax.plot(data[:, 0], data[:, 1], label=r"$ln(x)e^{-x^2}$")
plt.legend()
plt.xlabel(r"x")
plt.ylabel(r"y")
plt.grid()
plt.savefig(filename + ".png")
ax.cla()

