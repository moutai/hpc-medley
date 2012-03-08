import sys
f =open(sys.argv[1], "r")
fout= open ("myhostfile.txt","w")
previous_line=""
for line in f.readlines():
	if previous_line!=line:
		fout.write(line+"")
		previous_line=line			
f.close()

