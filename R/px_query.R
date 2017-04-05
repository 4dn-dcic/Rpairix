#' Query function on pairix-indexed pairs file.
#'
#' This function allows you to query a 2D range in a pairix-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param querystr a character vector containing a list of pairs of genomic coordinates in "chr1:start1-end1|chr2:start2-end2" format. start-end can be omitted (e.g. "chr1:start1-end1|chr2" or "chr1|chr2")
#' @param max_mem the total string length allowed for the result. If the size of the output exceeds this number, the function will return NULL and print out a memory error. Default 100,000,000.
#' @param stringsAsFactors the stringsAsFactors parameter for the data frame returned. Default False.
#' @param linecount.only If TRUE, the function returns an integer corresponding to the number of output lines instead of the actual query result. (default FALSE) 
#' @param autoflip If TRUE, the function will rerun on a flipped query (mate1 and mate2 swapped) if the original query results in an empty output. (default FALSE). If linecount.only option is used in combination with autoflip, the result count is on the flipped query in case the query gets flipped.
#'
#' @keywords pairix query 2D
#' @export px_query
#' @examples
#' 
#' ## 2D-indexed file
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' querystr = c("chr10|chr20","chr22|chr22")
#' res = px_query(filename, querystr)
#' print(res)
#'
#' n = px_query(filename, querystr, linecount.only=TRUE)
#' print(n) 
#'
#' querystr = "chr20|chr10"
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' ## the following attempts will return NULL and give you a warning message.
#' querystr = "chr20"
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' filename = system.file(".","merged_nodup.tab.chrblock_sorted.txt.gz", package="Rpairix")
#' querystr = "10:1-1000000|20"
#' res = px_query(filename, querystr)
#' print(res)
#'
#' ## the following attempts will return NULL and give you a warning message.
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' querystr = "10:1-1000000|20"
#' res = px_query(filename, querystr)
#' print(res)
#'
#' ## 1D-indexed file
#' filename = system.file(".","SRR1171591.variants.snp.vqsr.p.vcf.gz", package="Rpairix")
#' querystr = 'chr10|5000000-20000000'
#' res = px_query(filename, querystr)
#' print(res)
#' 
#' ## the following attempts will return NULL and give you a warning message.
#' querystr = 'chr10|chr20'
#' res = px_query(filename, querystr)
#' print(res)
#'
#' @useDynLib Rpairix get_size get_lines check_1d_vs_2d
px_query<-function(filename, querystr, max_mem=100000000, stringsAsFactors=FALSE, linecount.only=FALSE, autoflip=FALSE){

  # sanity check for 2D query on 1D index.
  ind_dim = .C("check_1d_vs_2d", filename, as.integer(0))
  if(ind_dim[[2]][1]==1 && length(grep('|',querystr, fixed=TRUE))>0) { message("2D query on 1D-indexed file?"); return(NULL) }

  # sanity check for autoflip on 1D query
  if(autoflip==TRUE && length(grep('|',querystr, fixed=TRUE))==0) { message("autoflip works only for 2D query."); return(NULL) }

  # first-round, get the max length and the number of lines of the result.
  out = .Call("get_size", filename, querystr, length(querystr))

  if(out[3] == -1 ) { message("Can't open input file"); return(NULL) }  ## error
  n=out[1]
  if(n==0 && autoflip==TRUE) {
    querystr=paste(strsplit(querystr,'|',fixed=TRUE)[[1]][c(2,1)],collapse="|")  ## flip mate1 and mate2
    out = .Call("get_size", filename, querystr, length(querystr))
    if(out[3] == -1 ) { message("Can't open input file"); return(NULL) }  ## error
    n=out[1]
    if(linecount.only == TRUE) return(n)
  }
  if(linecount.only == TRUE) return(n)

  str_len = out[2]
  total_size = str_len * n
  if(total_size > max_mem) {
     log = paste("not enough memory: Total length of the result to be stored is",total_size,sep=" ")
     message(log)
     return(NULL)
  }

  # second-round, actually get the lines from the file
  result_str = rep(paste(rep("a",str_len),collapse=''),n)
  out2 =.Call("get_lines", filename , querystr, length(querystr), n) 

  if(out2[[2]][1] == -1) return(NULL)  ## error

  ## tabularize
  res.table = as.data.frame(do.call("rbind",strsplit(out2[[1]],'\t')),stringsAsFactors=stringsAsFactors)
  return (res.table)
}


