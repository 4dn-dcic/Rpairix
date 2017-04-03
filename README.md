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
install_url("https://github.com/4dn-dcic/Rpairix/archive/0.0.8.zip")
```


## Available R functions
`px_query`, `px_keylist`, `px_seqlist`, `px_seq1list`, `px_seq2list`, `px_exists`, `px_chr1_col`, `px_chr2_col`, `px_startpos1_col`, `px_startpos2_col`, `px_endpos1_col`, `px_endpos2_col`, `px_check_dim`

## Usage
```
library(Rpairix)
px_query(filename,querystr) # query
px_query(filename,querystr,linecount.only=TRUE) # number of output lines for the query
px_keylist(filename) # list of keys (chromosome pairs)
px_seqlist(filename) # list of chromosomes
px_seq1list(filename) # list of first chromosomes
px_seq2list(filename) # list of second chromosomes
px_exists(filename,key) # check if a key exists
px_chr1_col(filename) # 1-based column index for mate1 chromosome
px_chr2_col(filename) # 1-based column index for mate2 chromosome
px_startpos1_col(filename) # 1-based column index for mate1 start position
px_startpos2_col(filename) # 1-based column index for mate2 start position
px_endpos1_col(filename) # 1-based column index for mate1 end position
px_endpos2_col(filename) # 1-based column index for mate2 end position
px_check_dim(filename) # returns 1 if the file is 1D-indexed, 2 if 2D-indexed. -1 if error.
```

### Query
```
px_query(filename,querystr,max_mem=100000000,stringsAsFactors=FALSE,linecount.only=FALSE, autoflip=FALSE)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* `querystr` (query string) is in the same format as the format for pairix. (e.g. '1:1-10000000|20:50000000-60000000')
* `max_mem` is the maximum total length of the result strings (sum of string lengths).
* The return value is a data frame, each row corresponding to the line in the input file within the query range.
* If `linecount.only` is TRUE, the function returns only the number of output lines for the query. 
* If `autoflip` is TRUE, the function will rerun on a flipped query (mate1 and mate2 swapped) if the original query results in an empty output. (default FALSE). If `linecount.only` option is used in combination with `autoflip`, the result count is on the flipped query in case the query gets flipped.

### List of keys (chromosome pairs)
```
px_keylist(filename)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of keys (chromosome pairs).

### List of chromosomes
```
px_seqlist(filename)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of chromosomes.

### List of first chromosomes
```
px_seq1list(filename)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of first chromosomes.

### List of second chromosomes
```
px_seq2list(filename)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is a vector of second chromosomes.

### Check if a chromosome pair (or chromosome, for 1D) exists
```
px_exists(filename, key)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* `key` is a chromosome pair (or a chromosome for 1D)
* The return value is 1 (exists), 0 (not exist), or -1 (error)

### Returns 1-based column indices
```
px_chr1_col(filename)
px_chr2_col(filename)
px_startpos1_col(filename)
px_startpos2_col(filename)
px_endpos1_col(filename)
px_endpos2_col(filename)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is an integer corresponding to the 1-based column index for mate1 chromosome, mate2 chromosome, mate1 start position, mate2 start position, mate1 end position and mate2 end position, respectively.


### Check 1D vs 2D
```
px_check_dim(filename)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* The return value is an integer; 1 if the input file is 1D-indexed, 2 if 2D-indexed, -1 if an error occurred.

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
>
> n = px_query(filename,querystr, linecount.only=TRUE)
> print(n)
> [1] 2
>
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000")
data frame with 0 columns and 0 rows
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000", autoflip=TRUE)
                   V1    V2      V3    V4      V5 V6 V7
1 SRR1658581.51740952 chr10  157600 chr20  167993  -  -
2 SRR1658581.33457260 chr10 2559777 chr20 7888262  -  +
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000", linecount.only=TRUE)
[1] 0
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000", autoflip=TRUE, linecount.only=TRUE)
[1] 2
>
>
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
>
> px_chr1_col("inst/test_4dn.pairs.gz")
[1] 2
> px_chr2_col("inst/test_4dn.pairs.gz")
[1] 4
> px_startpos1_col("inst/test_4dn.pairs.gz")
[1] 3
> px_startpos2_col("inst/test_4dn.pairs.gz")
[1] 5
> px_endpos1_col("inst/test_4dn.pairs.gz")
[1] 3
> px_endpos2_col("inst/test_4dn.pairs.gz")
[1] 5
> 
> px_check_dim("inst/test_4dn.pairs.gz")
[1] 2
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
### 0.0.8
* Further synced with pairix/pypairix 0.1.1.
* Function `px_check_dim` is now added.

### 0.0.7
* A 1D-indexed file is now added to `inst/` as an example file.
* `px_query`: 2D query on 1D-indexed file now gives a warning message.
* `px_query`: autoflip on 1D query gives a warning message even when the query result is not empty. 

### 0.0.6
* The `linecount.only` and `autoflip` options are now added to the `px_query` function.

### 0.0.5
* Functions `px_chr1_col`, `px_chr2_col`, `px_startpos1_col`, `px_startpos2_col`, `px_endpos1_col`, `px_endpos2_col` are now added.

### 0.0.4
* Function `px_exists` is now added.
* Source is synced with pairix/pypairix 0.1.1.
* 4dn pairs example is added

### 0.0.3
* corrected a typo in README

### 0.0.2
* cleaned up repo
* added more instructions in README

### 0.0.1
* initial release

