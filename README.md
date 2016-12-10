# Rpairix
An R package for querying on pairs file (pairix-indexed bgzipped text file containig a pair of genomic coordinates) 

## Installation
```
library(devtools)
install_github("4dn-dcic/Rpairix")
```

## Usage
```
library(Rpairix)
px_query(filename,querystr) # query
px_keylist(filename) # list of keys (chromosome pairs)
px_seqlist(filename) # list of chromosomes
px_seq1list(filename) # list of first chromosomes
px_seq2list(filename) # list of second chromosomes
```

