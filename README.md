# Rpairix
* Rpairix is an R package for indexing and querying on a compressed text file.
* Rpairix was developed as a tool for the 4DN-standard `pairs` file format describing Hi-C data: https://github.com/4dn-dcic/pairix/blob/master/pairs_format_specification.md
* However, it can be used as a generic tool for indexing and querying any bgzipped text file containing genomic coordinates, for either 2D- or 1D-indexing.
* For example, given a text file with a million lines like below, you want to extract lines where the first coordinate is chr10 and the second is between positions 10,000,000 and 20,000,000 on chrX. An awk command would read the file from the beginning to the end. Rpairix allows a faster query by accessing the file from a relevant position.

  **Pairs format**
  ```
  ## pairs format v1.0
  #sorted: chr1-chr2-pos1-pos2
  #shape: upper triangle
  #chromosomes: chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY chrM
  #genome_assembly: hg38
  #columns: readID chr1 pos1 chr2 pos2 strand1 strand2
  EAS139:136:FC706VJ:2:2104:23462:197393 chr1 10000 chr1 20000 + +
  EAS139:136:FC706VJ:2:8762:23765:128766 chr1 50000 chr1 70000 + +
  EAS139:136:FC706VJ:2:2342:15343:9863 chr1 60000 chr2 10000 + + 
  EAS139:136:FC706VJ:2:1286:25:275154 chr1 30000 chr3 40000 + -
  ```
  
  **Some custom text file**
  ```
  chr1  10000  20000 chr2  30000  50000  3.5
  chr1  30000  40000 chr3  10000  70000  4.6
  ```
* `Rpairix` is an R binder for `pairix` (https://github.com/4dn-dcic/pairix), a stand-alone C program that was written on top of `tabix` (https://github.com/samtools/tabix) and has been adapted to `pairs` and other common Hi-C data formats for 2D indexing and querying.

## Table of contents
* [Installation](#installation)
* [Available R functions](#available-r-functions)
* [Example run](#example-run)
* [Usage](#usage)
* [For developers](#for-developers)
* [Version history](#version-history)


## Installation
```r
library(devtools)
install_github("4dn-dcic/Rpairix")
```
If you have a problem loading the `Rpairix.so` file ('undefined symbol' error), try adding `PKG_LIBS = -lz` to `~/.R/Makevars`. This way, zlib will be linked during compilation.

Alternatively,
```
git clone https://github.com/4dn-dcic/Rpairix/
cd Rpairix
R --no-site-file --no-environ --no-save --no-restore CMD INSTALL --install-tests .
```
To install a specific version,
```
library(devtools)
install_url("https://github.com/4dn-dcic/Rpairix/archive/0.1.2.zip")
```


## Available R functions
`px_build_index`, `px_query`, `px_keylist`, `px_seqlist`, `px_seq1list`, `px_seq2list`, `px_exists`, `px_chr1_col`, `px_chr2_col`, `px_startpos1_col`, `px_startpos2_col`, `px_endpos1_col`, `px_endpos2_col`, `px_check_dim`, `px_get_column_names` 

```
library(Rpairix)
px_build_index(filename,preset) # indexing
px_query(filename,querystr) # querying
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
px_get_column_names(filename) # returns a vector of column names, if available. (works only for pairs format)
```

## Example run
```
> library(Rpairix)
>
> filename = "inst/test_4dn.pairs.gz"
>
> # indexing
> px_build_index(filename, sc=2, bc=3, ec=3, sc2=4, bc2=5, ec2=5, force=TRUE)
> px_build_index(filename, 'pairs', force=TRUE)  # equivalent to the above line (except the above way will not recognize column headings during query)
> px_build_index(filename, force=TRUE)  # equivalent to the above line, since file extension pairs.gz is recognized.
>
> # single-query
> querystr = "chr10:1-3000000|chr20"
> res = px_query(filename,querystr)
> print(res)
               readID  chr1    pos1  chr2    pos2 strand1 strand2
1 SRR1658581.51740952 chr10  157600 chr20  167993       -       -
2 SRR1658581.33457260 chr10 2559777 chr20 7888262       -       +
>
> # line-count-only
> n = px_query(filename,querystr, linecount.only=TRUE)
> print(n)
> [1] 2
>
> # auto-flip
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000")
data frame with 0 columns and 0 rows
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000", autoflip=TRUE)
               readID  chr1    pos1  chr2    pos2 strand1 strand2
1 SRR1658581.51740952 chr10  157600 chr20  167993       -       -
2 SRR1658581.33457260 chr10 2559777 chr20 7888262       -       +
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000", linecount.only=TRUE)
[1] 0
> px_query("inst/test_4dn.pairs.gz","chr20|chr10:1-3000000", autoflip=TRUE, linecount.only=TRUE)
[1] 2
>
> # multi-query
> querystr = c("chr10|chr20","chr2|chr20")
> n = px_query(filename,querystr, linecount.only=TRUE)
> print(n)
>
> # getting list of chromosome pairs and chromosomes
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
> 
> # checking if a key (chromosome pair for 2D-indexed file or chromosome for 1D-indexed file) exists
> px_exists(filename, "chr10|chr20")
[1] 1
>
> # getting colum indices
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
> # checking if the file is 1D-indexed or 2D-indexed
> px_check_dim("inst/test_4dn.pairs.gz")
[1] 2
>
> # get column names
> px_get_column_names("inst/test_4dn.pairs.gz")
[1] "readID"  "chr1"    "pos1"    "chr2"    "pos2"    "strand1" "strand2"
```

***

## Usage

### Indexing
```
px_build_index(filename, preset='', sc=0, bc=0, ec=0, sc2=0, bc2=0, ec2=0, delimiter='\t', comment_char='#', line_skip=0, force=FALSE)
```
* `filename` is sometextfile.gz (bgzipped text file)
* `preset` is one of the recognized formats: `gff`, `bed`, `sam`, `vcf`, `psltbl` (1D-indexing) or `pairs`, `merged_nodups`, `old_merged_nodups` (2D-indexing). If preset is '', at least some of the custom parameters must be given instead (`sc`, `bc`, `ec`, `sc2`, `bc2`, `ec2`, `delimiter`, `comment_char`, `line_skip`). (default '').  
* `sc` : first sequence (chromosome) column index (1-based). Zero (0) means not specified. If `preset` is given, `preset` overrides `sc`. If `preset` is not given, this one is required. (default 0)
* `bc` : first start position column index (1-based). Zero (0) means not specified. If `preset` is given, `preset` overrides `bc`. If `preset` is not given, this one is required. (default 0)
* `ec` : first end position column index (1-based). Zero (0) means not specified. If `preset` is given, `preset` overrides `ec`. (default 0)
sc2 second sequence (chromosome) column index (1-based). Zero (0) means not specified. If `preset` is given, `preset` overrides `sc2`. If `sc`, `bc` are specified but not `sc2` and `bc2`, it is 1D-indexed. (default 0)
* `bc2` : second start position column index (1-based). Zero (0) means not specified. If `preset` is given, `preset` overrides `bc2`. (default 0)
* `ec2` : second end position column index (1-based). Zero (0) means not specified. If `preset` is given, `preset` overrides `ec2`. (default 0)
* `delimiter` : delimiter (e.g. '\t' or ' ') (default '\t'). If `preset` is given, `preset` overrides `delimiter`.
* `comment_char` : comment character. Lines beginning with this character are skipped when creating an index. If `preset` is given, `preset` overrides `comment_char`. (default '#')
* `line_skip` : number of lines to skip in the beginning. (default 0)
* `force` : If TRUE, overwrite existing index file. If FALSE, do not overwrite unless the index file is older than the bgzipped file. (default FALSE)
* An index file sometextfile.gz.px2 will be created.
* When neither `preset` nor `sc`(and `bc`) is given, the following file extensions are automatically recognized: `gff.gz`, `bed.gz`, `sam.gz`, `vcf.gz`, `psltbl.gz` (1D-indexing), and `pairs.gz` (2D-indexing).

### Querying
```
px_query(filename,querystr,max_mem=100000000,stringsAsFactors=FALSE,linecount.only=FALSE, autoflip=FALSE)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist.
* `querystr` (query string) is in the same format as the format for pairix. (e.g. '1:1-10000000|20:50000000-60000000'). It can be a vector of query strings.
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

### Getting column names
```
px_get_column_names(filename)
```
* `filename` is sometextfile.gz and an index file sometextfile.gz.px2 must exist
* The return value is a vector of column names.
* Returns values only if the indexing must have been done with 'pairs' preset (either explicitly by setting a preset or by file extension recognition) and if the column heading information is available.

***



## For developers
When you modify the repo, rebuild the R package before your commit/push:
```
library(devtools)
setwd("Rpairix")
document()
```
Individual R functions are written and documented in `R/`. The `src/rpairixlib.c` is the main C source file. Raw data files are under `inst/`.

***

## Version history
### 0.1.2
* Function `px_get_column_names` is now added.
* `px_query` now adds column names for the query result if indexing was done with `pairs` preset.
* `px_query`: problem of merged_nodups query result not splitting by space is now fixed.

### 0.1.1
* `px_build_index`: When neither `preset` nor a custom set of columns is given, file extensions are automatically recognized for indexing.

### 0.1.0
* `px_build_index` is added. (Now indexing can be done using Rpairix as well as querying.)

### 0.0.9
* Multi-query now possible with function `px_query` (`querystr` can be a vector of strings).

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

