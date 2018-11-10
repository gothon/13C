import itertools as iter
import random
import math

#(inverts cannot be back to back)
# for 4: 1 - 2 inverts -> min 1 hot or cold

# I C HH (X) EASY
# I CC H     24
# II C H     12

# for 5: 2 inverts -> min 1 hot or cold

# II C HH (X) MEDIUM
# II CC H

# for 6: 2-3 inverts -> min 1 hot or cold

# II C HHH (X) VERY HARD
# II CC HH
# II CCC H
# III C HH
# III CC H

# for 7: 2-3 inverts -> min 2 hot or cold

# II CC HHH (X) HARD
# II CCC HH
# III CC HH

# pick a solution (in terms of count)
# get all valid permutations


COLORS = 16

	
#for each index, compute bottom 2 (computed randomly, preferentially ignoring 0 and 8 if all equal) for each start position
	
start_combo = {4: ['ICHH', 'ICCH', 'IICH'],
			   5: ['IICHH', 'IICCH', 'IIICH', 'IIICC', 'IIIHH'],
			   6: ['IICHHH', 'IICCHH', 'IICCCH', 'IIICHH', 'IIICCH'],
			   7: ['IICCHHH', 'IICCCHH', 'IIICCHH', 'IICCCCH', 'IIICCCH']}

for ops in range(4, 8):		
	print()
	print('Ops: {}'.format(ops))
	
	combo_list = []
	for combo in start_combo[ops]:
		print(combo)
		perms = list(list(iter.permutations(combo)))
		
		target_list = []
		for start in range(0, COLORS):
			if (start != 0) and (start != (COLORS/2)):
				cur_bins = [0]*COLORS
				for perm in perms:
					cur_color = start
					for op in perm:
						if op == 'I':
							cur_color = (cur_color + (COLORS/2)) % COLORS
						if op == 'C':
							if (cur_color != 0) and (cur_color != (COLORS/2)):
								if cur_color > (COLORS/2):
									cur_color = (cur_color - 1) % COLORS
								else:
									cur_color = (cur_color + 1) % COLORS
						if op == 'H':
							if (cur_color != 0) and (cur_color != (COLORS/2)):
								if cur_color > (COLORS/2):
									cur_color = min(cur_color + 2, COLORS) % COLORS
								else:
									cur_color = max(cur_color - 2, 0) % COLORS
					cur_color = int(cur_color)
					cur_bins[cur_color] += 1
				
				bins_and_indices = [{'index': i, 'bin_weight': (cur_bins[i] + (0.5 if ((i == 0) or (i == COLORS/2)) else 0.0)) if cur_bins[i] != 0 else 999999} for i in range(0, COLORS)]
				bins_and_indices.sort(key=lambda x: x['bin_weight'])
				sorted_indices = [bi['index'] for bi in bins_and_indices] 
				target_list.append([sorted_indices[0], sorted_indices[1]])
		combo_list.append(target_list)
	print(combo_list)






