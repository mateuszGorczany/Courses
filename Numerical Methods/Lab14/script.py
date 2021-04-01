import numpy as np
from matplotlib import pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.ticker import MaxNLocator

fig, ax = plt.subplots()

plt.rcParams.update({'font.size': 21})
ax.tick_params(axis='both', labelsize=21)
ax.xaxis.label.set_size(20)
ax.yaxis.label.set_size(20)
plt.tight_layout()
"""
for i in range(1,4):
    filename = "U_1"
    data = np.loadtxt(filename + ".txt")
    ax.plot(data[:, 0], data[:, i], marker="o", ls="", label=r"$x\in U_1(0,1)$")
    ax.autoscale(enable=True, axis="y", tight=False)
    plt.title(r"$X_{i+%s}(X_i)$" % (i))
    plt.legend()
    plt.xlabel(r"$X_i$")
    plt.ylabel(r"$X_{i+%s}$" %(i))

    plt.grid()
    plt.savefig(filename + f"_{i}.png")
    ax.cla()

for i in range(1,4):
    filename = "U_2"
    data = np.loadtxt(filename + ".txt")
    ax.plot(data[:, 0], data[:, i], marker="o", ls="", label=r"$x\in U_2(0,1)$")
    ax.autoscale(enable=True, axis="y", tight=False)
    plt.title(r"$X_{i+%s}(X_i)$" % (i))
    plt.legend()
    plt.xlabel(r"$X_i$")
    plt.ylabel(r"$X_{i+%s}$" %(i))

    plt.grid()
    plt.savefig(filename + f"_{i}.png")
    ax.cla()

for i in range(1,4):
    filename = "U_3"
    data = np.loadtxt(filename + ".txt")
    ax.plot(data[:, 0], data[:, i], marker="o", ls="", label=r"$x\in U_3(0,1)$")
    ax.autoscale(enable=True, axis="y", tight=False)
    plt.title(r"$X_{i+%s}(X_i)$" % (i))
    plt.legend()
    plt.xlabel(r"$X_i$")
    plt.ylabel(r"$X_{i+%s}$" %(i))

    plt.grid()
    plt.savefig(filename + f"_{i}.png")
    ax.cla()

"""

#plt.ticklabel_format(axis='both', style='sci', scilimits=(0,0))
fig, ax = plt.subplots()
filename = "2000_dens"
data = np.loadtxt(filename + ".txt")

ax.bar(data[:,0] + 0.00, data[:,1], color = 'b', width = 0.25, label=r"$n_j$")
ax.bar(data[:,0] + 0.25, data[:,2], color = 'g', width = 0.25, label=r"$g_j$")
ax.xaxis.set_major_locator(MaxNLocator(integer=True))
plt.title(r"N=2000")
plt.legend()
plt.xlabel(r"$j$")
plt.ylabel(r"$g_j, n_j$")
plt.tight_layout()
plt.grid()
plt.savefig(filename + ".png")
ax.cla()

filename = "10_4_dens"
data = np.loadtxt(filename + ".txt")

ax.bar(data[:,0] + 0.00, data[:,1], color = 'b', width = 0.25, label=r"$n_j$")
ax.bar(data[:,0] + 0.25, data[:,2], color = 'g', width = 0.25, label=r"$g_j$")
plt.ticklabel_format(axis='y',style='sci',scilimits=(0,3))
ax.xaxis.set_major_locator(MaxNLocator(integer=True))
plt.title(r"N=10000")
plt.legend()
plt.xlabel(r"$j$")
plt.ylabel(r"$g_j, n_j$")
plt.tight_layout()
plt.grid()
plt.savefig(filename + ".png")
ax.cla()


filename = "10_7_dens"
data = np.loadtxt(filename + ".txt")
ax.bar(data[:,0] + 0.00, data[:,1], color = 'b', width = 0.25, label=r"$n_j$")
ax.bar(data[:,0] + 0.25, data[:,2], color = 'g', width = 0.25, label=r"$g_j$")
plt.ticklabel_format(axis='y',style='sci',scilimits=(0,3))
ax.xaxis.set_major_locator(MaxNLocator(integer=True))
plt.title(r"N=10000000")
plt.xlabel(r"$j$")
plt.ylabel(r"$g_j, n_j$")
plt.legend()
plt.tight_layout()
plt.grid()
plt.savefig(filename + ".png")
ax.cla() 


data = np.loadtxt("Vectors.txt")
fig = plt.figure()
ax = plt.axes(projection="3d")
ax.scatter3D(data[:,0], data[:,1], data[:,2], "grey")
plt.savefig("sphere.png")
ax.cla()

data = np.loadtxt("filled_sphere.txt")

ax.scatter3D(data[:,0], data[:,1], data[:,2], "grey")
plt.savefig("f_sphere.png")
ax.cla()
