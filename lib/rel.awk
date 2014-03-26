# real.awk - awk relational query processor

BEGIN { 
	readrel("DATADIR/relfile")
}
/./  { doquery($0) }

function readrel(f) {
	while (getline <f > 0) {
		if ($0 ~ /^[A-Za-z\/\.]+ *:/) {
			gsub(/[^A-Za-z\/\.]+/, "", $0)
			relname[++nrel] = $0
		} else if ($0 ~ /^[ \t]*!/) {
			cmd[nrel, ++ncmd[nrel]] = substr($0, index($0, "!")+1)
		} else if ($0 ~ /^[ \t]*[A-Za-z1-9\_]+[ \t]*$/) {
			attr[nrel, $1] = ++nattr[nrel]
		} else if ($0 !~ /^[ \t]*$/) {
			print "bad line in relfile:" $0
		}
	}
}

function doquery(s, i, j) {
	for (i in qattr)
		delete qattr[i]
	query = s
	while (match(s, /\$[A-Za-z]+/)) {
		qattr[substr(s, RSTART+1, RLENGTH-1)] = 1
		s = substr(s, RSTART+RLENGTH+1)
	}
	for (i = 1; i <= nrel && !subset(qattr, attr, i); )
		i++
	if (i > nrel)
		missing(qattr)
	else {
		for (j in qattr)
			gsub("\\$" j, "$" attr[i,j], query)
		for (j = 1; j <= ncmd[i]; j++)
			if (system(cmd[i, j]) != 0) {
				print "command failed, query skipped\n", cmd[i,j]
				return
			}
		awkcmd = sprintf("awk -F',' '%s' %s", query, relname[i])
		printf("query: %s\n", awkcmd)
		system(awkcmd)
	}
}

function subset(q, a, r, i) {
	for (i in q) {
		if (!((r,i) in a)) {
			return 0
		}
	}
	return 1
}

function missing(x, i) {
	print "no table contains all of the following attributes:"
	for (i in x) {
		print i
	}
}
