#' Query function on pairix-indexed pairs file.
#'
#' This function allows you to query a 2D range in a pairix-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param querystr a pair of genomic coordinates in "chr1:start1-end1|chr2:start2-end2" format. start-end can be omitted (e.g. "chr1:start1-end1|chr2" or "chr1|chr2")
#' @param max_mem the total string length allowed for the result. If the size of the output exceeds this number, the function will return NULL and print out a memory error. Default 100,000,000.
#' @param stringsAsFactors the stringsAsFactors parameter for the data frame returned. Default False.
#' @param linecount.only If TRUE, the function returns an integer corresponding to the number of output lines instead of the actual query result. (default FALSE) 
#' @param autoflip If TRUE, the function will rerun on a flipped query (mate1 and mate2 swapped) if the original query results in an empty output. (default FALSE). If linecount.only option is used in combination with autoflip, the result count is on the flipped query in case the query gets flipped.
#'
#' @keywords pairix query 2D
#' @export px_query
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' querystr = "chrX|chrX"
#' res = px_query(filename, querystr)
#' print(res)
#'
#' n = px_query(filename, querystr, linecount.only=TRUE)
#' print(n) 
#'
#' filename = system.file(".","merged_nodup.tab.chrblock_sorted.txt.gz", package="Rpairix")
#' querystr = "10:1-1000000|20"
#' res = px_query(filename, querystr)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' querystr = "10:1-1000000|20"
#' res = px_query(filename, querystr)
#' print(res)
#'
#' @useDynLib Rpairix get_size get_lines
px_query<-function(filename, querystr, max_mem=100000000, stringsAsFactors=FALSE, linecount.only=FALSE, autoflip=FALSE){

  # first-round, get the max length and the number of lines of the result.
  out =.C("get_size", filename, querystr, as.integer(0), as.integer(0), as.integer(0))
  if(out[[5]][1] == -1 ) { message("Can't open input file"); return(NULL) }  ## error
  n=out[[3]][1]
  if(n==0 && autoflip==TRUE) {
    if(length(grep("|",querystr))) {
      querystr=paste(strsplit(querystr,'|',fixed=TRUE)[[1]][c(2,1)],collapse="|")  ## flip mate1 and mate2
      out =.C("get_size", filename, querystr, as.integer(0), as.integer(0), as.integer(0))
      if(out[[5]][1] == -1 ) { message("Can't open input file"); return(NULL) }  ## error
      n=out[[3]][1]
      if(linecount.only == TRUE) return(n)
    } else {
      message("autoflip works only for 2D query."); return(NULL)
    }
  }
  if(linecount.only == TRUE) return(n)

  str_len = out[[4]][1]
  total_size = str_len * n
  if(total_size > max_mem) {
     log = paste("not enough memory: Total length of the result to be stored is",total_size,sep=" ")
     message(log)
     return(NULL)
  }

  # second-round, actually get the lines from the file
  result_str = rep(paste(rep("a",str_len),collapse=''),n)
  out2 =.C("get_lines", filename , querystr, result_str, as.integer(0))
  if(out2[[4]][1] == -1) return(NULL)  ## error

  ## tabularize
  res.table = as.data.frame(do.call("rbind",strsplit(out2[[3]],'\t')),stringsAsFactors=stringsAsFactors)
  return (res.table)
}


