from __future__ import print_function  # allow it to run on python2 and python3

import numpy as np
from dwave.system.samplers import DWaveSampler
from dwave.system.composites import EmbeddingComposite
from array import *

# load matrix
qubomatrix = np.loadtxt('qubomatrix.txt')
print('Loaded matrix:\n', qubomatrix, '\n')

# convert into QUBO
qubo = {(i,i):0.0 for i in range(len(qubomatrix))}
for index,value in np.ndenumerate(qubomatrix):
    if value != 0:
        qubo[index] = value
print('Converted matrix into QUBO for D-Wave:\n', qubo, '\n')

responses = []

reads_per_request = 100

#num_reads_times_hundred
num_reads_times_hundred = input("How many Requests (each "+str(reads_per_request)+") [10]: ")
if num_reads_times_hundred == "":
	num_reads_times_hundred = 10
num_reads_times_hundred = int(num_reads_times_hundred)

#annealing_time
annealing_time = input("Annealing time [20]: ")
if annealing_time == "":
	annealing_time = 20
annealing_time = int(annealing_time)

#annealing_time
chain_strength = input("chain strength [10]: ")
if chain_strength == "":
	chain_strength = 10
chain_strength = int(chain_strength)

print("\n")
print("num_reads_times_hundred = ",num_reads_times_hundred,"; annealing time = ", annealing_time,"; chain_strength = ", chain_strength)
print("\n")

for read in range(1,num_reads_times_hundred+1):
	sampler = EmbeddingComposite(DWaveSampler())
	responses.append(sampler.sample_qubo(qubo, num_reads=reads_per_request, annealing_time=annealing_time, chain_strength=chain_strength))
	#print('Response ',read,' from the D-Wave:\n', responses[read], '\n')
	print('Saved result from request ',read,' in results.txt','   ',read*reads_per_request,' from ',num_reads_times_hundred*reads_per_request)

	with open('results.txt','w') as file:
		file.write('numreads = %f; annealing_time = %d; chain_strength = %s\n' % ((num_reads_times_hundred*100), annealing_time,chain_strength))
		for response in responses:
			for sample, energy, num_occurrences, cbf in response.record:
				file.write('%f\t%g\t%d\t%s\n' % (energy,cbf, num_occurrences, np.array2string(sample, max_line_width=None).replace('\n','')))
				#file.write('\n')
print('Saved all results in results.txt')
