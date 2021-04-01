import numpy as np
from matplotlib import pyplot as plt

file = "Eigenvalues.txt"
data = np.loadtxt(file)
alfa = data[:, 0]
vals = data[:, 1:]

ax = plt.gca() 

for i in np.arange(0, 6):
    plt.plot(alfa, vals[:, i], '.-', label = r'$\omega_{%s} = \sqrt{\lambda_{%s}}$' % (i+1,i+1))

ax.legend(loc = 'upper right')
plt.xlabel(r'$\alpha$')
plt.ylabel(r'$\sqrt{\lambda}$')
plt.savefig("eigvals.png")
