# Rpairix
* An R package for querying on pairs file (pairix-indexed bgzipped text file containig a pair of genomic coordinates).
* This is an R binder for Pairix, a stand-alone C program (https://github.com/4dn-dcic/pairix).

## Table of contents
* [Installation](#installation)
* [Available R functions](#available-r-functions)
* [Usage](#usage)
* [Example run](#example-run)
* [For developers](#for-developers)
* [Version history](#version-history)


## Installation
```r
library(devtools)
install_github("4dn-dcic/Rpairix")
```
If you have a problem loading the Rpairix.so file ('undefined symbol' error), try adding `PKG_LIBS = -lz` to `~/.R/Makevars`. This way, zlib will be linked during compilation.

Alternatively,
```
git clone https://github.com/4dn-dcic/Rpairix/
cd Rpairix
R --no-site-file --no-environ --no-save --no-restore CMD INSTALL --install-tests .
```
To install a specific version,
```
library(devtools)
install_url("https://github.com/4dn-dcic/Rpairix/archive/0.0.4.zip")
```


## Available R functions
`px_query`, `px_keylist`, `px_seqlist`, `px_seq1list`, `px_seq2list`, `px_exists`

## Usage
```
library(Rpairix)
px_query(filename,querystr) # query
px_keylist(filename) # list of keys (chromosome pairs)
px_seqlist(filename) # list of chromosomes
px_seq1list(filename) # list of first chromosomes
px_seq2list(filename) # list of second chromosomes
px_exists(filename,key) # check if a key exists
```

### Query
```
px_query(filename,querystr,max_mem=100000000,stringsAsFactors=FALSE)
```
* The filename is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The query string is in the same format as the format for pairix. (e.g. '1:1-10000000|20:50000000-60000000')
* The max_mem is the maximum total length of the result strings (sum of string lengths). 
* The return value is a data frame, each row corresponding to the line in the input file within the query range.

### List of keys (chromosome pairs)
```
px_keylist(filename)
```
* The filename is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of keys (chromosome pairs).

### List of chromosomes
```
px_seqlist(filename)
```
* The filename is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of chromosomes.

### List of first chromosomes
```
px_seq1list(filename)
```
* The filename is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of first chromosomes.

### List of second chromosomes
```
px_seq2list(filename)
```
* The filename is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of second chromosomes.

### Check if a chromosome pair (or chromosome, for 1D) exists
```
px_exists(filename, key)
```
* The filename is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* Key is a chromosome pair (or a chromosome for 1D)
* The return value is 1 (exists), 0 (not exist), or -1 (error)

## Example run
```
> library(Rpairix)
> filename = "inst/test_4dn.pairs.gz"
> querystr = "chr10:1-3000000|chr20"
> res = px_query(filename,querystr)
> print(res)
                   V1    V2      V3    V4      V5 V6 V7
1 SRR1658581.51740952 chr10  157600 chr20  167993  -  -
2 SRR1658581.33457260 chr10 2559777 chr20 7888262  -  +
> keys = px_keylist(filename)
> length(keys)
[1] 800
> keys[1:10]
 [1] "chr1|chr1"            "chr1|chr10"           "chr1|chr11"          
 [4] "chr1|chr12"           "chr1|chr13"           "chr1|chr14"          
 [7] "chr1|chr15"           "chr1|chr16"           "chr1|chr17"          
[10] "chr1|chr17_ctg5_hap1"
> chrs = px_seqlist(filename)
> length(chrs)
[1] 82
> chrs[1:10]
 [1] "chr1"                  "chr1_gl000191_random"  "chr1_gl000192_random" 
 [4] "chr10"                 "chr11"                 "chr11_gl000202_random"
 [7] "chr12"                 "chr13"                 "chr14"                
[10] "chr15"                
> px_exists(filename, "chr10|chr20")
[1] 1
```


## For developers
When you modify the repo, rebuild the R package before your commit/push:
```
library(devtools)
setwd("Rpairix")
document()
```
Individual R functions are written and documented in `R/`. The `src/rpairixlib.c` is the main C source file. Raw data files are under `inst/`.


## Version history
### 0.0.4
* Function px_exists is now added.
* Source is synced with pairix/pypairix 0.1.1.
* 4dn pairs example is added

### 0.0.3
* corrected a typo in README

### 0.0.2
* cleaned up repo
* added more instructions in README

### 0.0.1
* initial release

