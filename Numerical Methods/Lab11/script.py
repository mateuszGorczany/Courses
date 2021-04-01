import numpy as np
import matplotlib.pyplot as plt

ax = plt.gca()

for file, i in zip(["k6.txt", "k8.txt", "k10.txt"], [6, 8, 10]):
    plt.title(f"k={i}")
    data = np.loadtxt(file)
    plt.plot(data[:, 0], data[:, 1], label="sygnał niezaszumiony")
    plt.plot(data[:, 0], data[:, 2], label="sygnał odszumiony")
    plt.legend()
    plt.xlabel("i")
    plt.ylabel("y")
    plt.grid()
    plt.savefig(file.replace(".txt", ".png"))
    ax.cla()


data = np.loadtxt("k10_noise.txt")
plt.title(f"k={10}")
plt.plot(data[:, 0], data[:, 1], label="sygnał zaszumiony")
plt.legend()
plt.xlabel("i")
plt.ylabel("y")
plt.grid()
plt.savefig("noise.png")
ax.cla()


data = np.loadtxt("k10_fourier.txt")
plt.title(f"k={10}")
plt.plot(data[:, 0], data[:, 1], label="Transformata Fouriera")
plt.legend()
plt.xlabel(r"$\omega$")
# plt.ylabel("y")
plt.grid()
# plt.xscale("log")

plt.savefig("forier.png")
ax.cla()


data = np.loadtxt("k10_fourier_zoom.txt")
plt.title(f"k={10}")
plt.plot(data[:, 0], data[:, 1], label="Transformata Fouriera")
plt.legend()
plt.xlabel(r"$\omega$")
# plt.ylabel("y")
plt.grid()
plt.savefig("fourier_zoom.png")
ax.cla()