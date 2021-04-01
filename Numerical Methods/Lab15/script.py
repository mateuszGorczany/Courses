import numpy as np
import math
from matplotlib import pyplot as plt


u = 1.66e-27
m = 40.*u
k = 1.38e-23
T = 100
sigma = math.sqrt(k*T/m)
delta_V = 5.*sigma/30.

fig, ax = plt.subplots()
ax.yaxis.label.set_size(14)


filename = "H1e3"
data = np.loadtxt(filename + ".txt")

filename2 = "F1e3"
data2 = np.loadtxt(filename2 + ".txt")
data2 = np.array(sorted(data2, key=lambda x: x[0]))
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, color="tab:blue",  alpha=0.6, label=r"$\Phi_i$")
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, edgecolor="tab:blue", facecolor="None")
ax.plot(data2[:,0], data2[:,1], color="tab:red", label="f(V)")
plt.title(r"$N_L=10^3$")
plt.legend()
plt.xlabel(r"V[m]")
plt.ylabel(r"$\Phi_i$")
plt.tight_layout()
plt.grid()
plt.savefig(filename + ".png")
ax.cla()

filename = "H1e4"
data = np.loadtxt(filename + ".txt")

filename2 = "F1e4"
data2 = np.loadtxt(filename2 + ".txt")
data2 = np.array(sorted(data2, key=lambda x: x[0]))
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, color="tab:blue",  alpha=0.7, label=r"$\Phi_i$")
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, edgecolor="tab:blue", facecolor="None")
ax.plot(data2[:,0], data2[:,1], color="tab:red", label="f(V)")
plt.title(r"$N_L=10^4$")
plt.legend()
plt.xlabel(r"V[m]")
plt.ylabel(r"$\Phi_i$")
plt.tight_layout()
plt.grid()
plt.savefig(filename + ".png")
ax.cla()


filename = "H1e5"
data = np.loadtxt(filename + ".txt")

filename2 = "F1e5"
data2 = np.loadtxt(filename2 + ".txt")
data2 = np.array(sorted(data2, key=lambda x: x[0]))
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, color="tab:blue",  alpha=0.7, label=r"$\Phi_i$")
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, edgecolor="tab:blue", facecolor="None")
ax.plot(data2[:,0], data2[:,1], color="tab:red", label="f(V)")
plt.title(r"$N_L=10^5$")
plt.legend()
plt.xlabel(r"V[m]")
plt.ylabel(r"$\Phi_i$")
plt.tight_layout()
plt.grid()
plt.savefig(filename + ".png")
ax.cla()

filename = "H1e6"
data = np.loadtxt(filename + ".txt")

filename2 = "F1e6"
data2 = np.loadtxt(filename2 + ".txt")
data2 = np.array(sorted(data2, key=lambda x: x[0]))
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, color="tab:blue",  alpha=0.7, label=r"$\Phi_i$")
ax.bar(data[:,0]*delta_V+0.5*delta_V, data[:,1], width=delta_V, edgecolor="tab:blue", facecolor="None")
ax.plot(data2[:,0], data2[:,1], color="tab:red", label="f(V)")
plt.title(r"$N_L=10^6$")
plt.legend()
plt.xlabel(r"V[m]")
plt.ylabel(r"$\Phi_i$")
plt.tight_layout()
plt.grid()
plt.savefig(filename + ".png")
ax.cla()