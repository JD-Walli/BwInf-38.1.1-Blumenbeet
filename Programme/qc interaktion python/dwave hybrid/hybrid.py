from __future__ import print_function  # allow it to run on python2 and python3
import numpy as np
from dwave.system.samplers import DWaveSampler
from dwave.system.composites import EmbeddingComposite
import dimod
import hybrid
# load matrix
qubomatrix = np.loadtxt('qubomatrix.txt')
print('Loaded matrix:\n', qubomatrix, '\n')
# convert into QUBO
qubo = {(i,i):0.0 for i in range(len(qubomatrix))}
# necessary to keep the order of the sample columns consistent
for index,value in np.ndenumerate(qubomatrix):
    if value != 0:
        qubo[index] = value
print('Converted matrix into QUBO for D-Wave:\n', qubo, '\n')
# Define the workflow
iteration = hybrid.RacingBranches(
    hybrid.InterruptableTabuSampler(),
    hybrid.EnergyImpactDecomposer(size=2)
    | hybrid.QPUSubproblemAutoEmbeddingSampler()
    | hybrid.SplatComposer()
) | hybrid.ArgMin()
workflow = hybrid.LoopUntilNoImprovement(iteration, convergence=3)

# Solve the problem
init_state = hybrid.State.from_problem(qubo)
final_state = workflow.run(init_state).result()
print("Solution: sample={.samples.first}".format(final_state))
# save results in results.txt
#with open('results.txt','w') as file:
    #file.write('energy\tnum_occurrences\tsample\n')
    #for sample, energy, num_occurrences, cbf in response.record:
    #    file.write('%f\t%g\t%d\t%s\n' % (energy,cbf, num_occurrences, sample))
    #print('Saved results in results.txt')
