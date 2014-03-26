# real.awk - awk relational query processor
# Generously cribbed from qawk.awk from The Awk Programming Language

BEGIN { readrel("DATADIR/relfile") }
/./  { parseqattr($0) }
END { doquery() }

function readrel(f) {
	while (getline <f > 0) {
		if ($0 ~ /^[A-Za-z\/\.]+ *:/) {
			gsub(/[^A-Za-z\/\.]+/, "", $0)
			relname[++nrel] = $0
		} else if ($0 ~ /^[ \t]*[A-Za-z1-9\_]+[ \t]*$/) {
			attr[nrel, $1] = ++nattr[nrel]
		} else if ($0 !~ /^[ \t]*$/) {
			print "bad line in relfile:" $0
		}
	}
}

function parseqattr(s, q) {
	q = s
	query[nq++] = q
	while (match(s, /\$[A-Za-z]+/)) {
		qattr[substr(s, RSTART+1, RLENGTH-1)] = 1
		s = substr(s, RSTART+RLENGTH+1)
	}
}

function doquery() {
	for (i = 1; i <= nrel && !subset(qattr, attr, i); )
		i++
	if (i > nrel)
		missing(qattr)
	for (n=0; n < length(query); n++) {
		for (j in qattr)
			gsub("\\$" j, "$" attr[i,j], query[n])
		qfile = ".query.tmp"
		system(sprintf("printf '%%s\n' '%s' >> %s", query[n], qfile))
	}
	system(sprintf("awk -F',' -f %s %s", qfile, relname[i]))
	system(sprintf("rm -f %s", qfile))
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
	exit 1
}
