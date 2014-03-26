sabr
===

## Description
Sabr is a sabermetrics analysis tool utilizing a CSV-based relational database.

## Basics
Most Sabermetrics data is distributed as CSV files. While parsing CSV's is relatively simple,
queries can become unfathomable when filled with field numbers. Using the same technique
describe is The Awk Programming Lanugage, we create a file with relations from field names to field
numbers. This drastically increases one's ability to write and read queries.

## Getting Started
There's a few steps necessary to boostrapping your environment.

### Installation
```
make install
```

### Creating Initial Tables & Headers
```
curl http://seanlahman.com/files/database/lahman-csv_2014-02-14.zip -o stats.zip
unzip stats.zip -d stats
cd stats
sabr-bootstrap ./
```

### Query
```
sabr query '$nameLast ~ /Longoria/ { print $nameFirst }'
```
