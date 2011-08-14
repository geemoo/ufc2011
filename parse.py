#!/usr/bin/python

import re

pid=0
mid=0
cid=0

camps = [
	[1, "10th Planet Jiu-Jitsu" ],
	[2, "Alliance Center" ],
	[3, "AMC Pankration" ],
	[4, "American Kickboxing Academy" ],
	[5, "American Top Team" ],
	[6, "Arizona Combat Sports" ],
	[7, "Brazilian Top Team" ],
	[8, "Cesar Gracie Jiu-Jitsu" ],
	[9, "Extreme MMA" ],
	[10, "Greg Jackson's Gym" ],
	[11, "Minnesota Martial Arts Academy" ],
	[12, "Rough House" ],
	[13, "Serra Jiu-Jitsu" ],
	[14, "Sityodtong" ],
	[15, "Team Blackhouse" ],
	[16, "Team Higashi" ],
	[17, "Team Link" ],
	[18, "Team Militant" ],
	[19, "Team Penn" ],
	[20, "Team Punishment" ],
	[21, "Team Quest" ],
	[22, "Team Tompkins" ],
	[23, "The Arena" ],
	[24, "The HIT Squad" ],
	[25, "The Pit" ],
	[26, "Wolfslair MMA Academy" ],
	[27, "Zahabi MMA" ]
]

# open file
fp = open('movelist.txt')

# loop through all lines
for line in fp.readlines():
	# if it starts with \d\d\d, it's a new position
	if (re.search('^=P=', line)):
		# extract the id
		bits = re.search('^=P= (\d\d\d) .*', line)
		pid = bits.group(1)
		pid = int(pid, 10)
	elif (re.search('^=M=', line)):
		# extract the name and requirements
		bits = re.search('^=M= ([^=]*)(=== Requires (.*))?', line)
		move = bits.group(1).strip()
		req = bits.group(3)
		mid = mid + 1
		#print "MOVES_TO_POSITIONS_SQL: insert into moves_positions (move_id, position_id) values (%d, %d);" % (mid, pid);
		#print "MOVES_SQL: insert into moves (id,name,reqstring) values (%d, $$%s$$, $$%s$$);" % (mid, move, req)

	elif (re.search('^=C=', line)):
		# extract the camp name
		bits = re.search('^=C= (.*)', line)
		campname = bits.group(1)

		cid = 0
		for i in camps:
			if (i[1] == campname):
				cid = i[0]
				break

		#print "MOVE_TO_CAMP_SQL: insert into moves_camps (move_id, camp_id) values (%d, %d);" % (mid, cid)
