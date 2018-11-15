import itertools as iter
import random
import math
import copy

# pick a start row, 1 - 3
# pick subsequent rows 80% other 2, 20% repeat



# when picking final, make sure none match 1st

def pickNETo(value, length=3):
	return (((value - 1) + random.randint(1, length-1)) % length) + 1

def produceList(length, elements):
	pots = []
	while (len(pots) == 0) or ((pots[0][0] == pots[length - 1][0]) and (pots[0][0] != -1))  or ((pots[0][1] == pots[length - 1][1]) and (pots[0][1] != -1)) or ((pots[0][2] == pots[length - 1][2]) and (pots[0][2] != -1)):
		pots.clear()
		last_start = -1
		start = 0
		value = -1
		for i in range(length):
			last_value = value
			if last_start == -1:
				start = random.randint(1, 3)
				value = random.randint(1, elements)
			elif i != (length - 1):
				if random.random() < 0.8:
					start = pickNETo(last_start)
					value = random.randint(1, elements)
				else:
					start = last_start
					
			plant = [-1, -1, -1]
			if last_value != -1:
				plant[last_start - 1] = last_value
			plant[start - 1] = value
			pots.append(plant)
			last_start = start

	first_time_through = True
	old_pots = copy.deepcopy(pots)
	while first_time_through or (pots[0][0] == pots[length - 1][0]) or (pots[0][1] == pots[length - 1][1]) or (pots[0][2] == pots[length - 1][2]):
		pots = copy.deepcopy(old_pots)
		first_time_through = False
		for i in range(length):
			for q in range(3):
				if pots[i][q] == -1:
					new_index = random.randint(1, elements)
					if random.random() < 0.5:
						if i == 0:
							while new_index == pots[i + 1][q]:
								new_index = random.randint(1, elements)
						elif i == (length - 1):
							while new_index == pots[i - 1][q]:
								new_index = random.randint(1, elements)					
						else:
							while (new_index == pots[i - 1][q]) or (new_index == pots[i + 1][q]):
								new_index = random.randint(1, elements)
					pots[i][q] = new_index
						
						
	return pots
	
def calcDifficulty(pots, start=3):
	SAMPLES = 100000
	solutions = 0.0
	for _ in range(SAMPLES):
		solutions += 1
		random.shuffle(pots)
		cur_p = 0
		break_out = False
		for run_l in range(start, start+3):
			
			cur_p += 1
			for i in range(1, run_l):
				if (pots[cur_p][0] != pots[cur_p - 1][0]) and (pots[cur_p][1] != pots[cur_p - 1][1]) and (pots[cur_p][2] != pots[cur_p - 1][2]):
					solutions -= 1
					break_out = True
					break
				cur_p += 1
			
			if break_out: 
				break
	return solutions / SAMPLES
		
	

#list_all = []
#average = 0
#count = 0
#while True:
#	if (count % 10) == 0:
#		list_all = produceList(3, 4) + produceList(4, 4) + produceList(5, 4)
#
#	count += 1
#	average += calcDifficulty(list_all, 3)
#	print(average / count)

list_all = produceList(3, 3) + produceList(4, 3) + produceList(5, 3)
random.shuffle(list_all)


#print(listA)
#print(listB)
#print(listC)

#for _ in range(100):
#	print()

print(list_all)

