#' Query function on pairix-indexed pairs file.
#'
#' This function allows you to query a 2D range in a pairix-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param querystr a pair of genomic coordinates in "chr1:start1-end1|chr2:start2-end2" format. start-end can be omitted (e.g. "chr1:start1-end1|chr2" or "chr1|chr2")
#' @param max_mem the total length allowed for the result. If the size of the output exceeds this number, the function will return NULL and print out a memory error.
#'
#' @keywords pairix query 2D
#' @export px_query
#' @examples
#' filename = system.file(".","merged_nodup.tab.chrblock_sorted.txt.gz",package="Rpairix")
#' querystr = "10:1-1000000|20"
#' res = px_query(filename,querystr)
#' @useDynLib Rpairix get_size get_lines
px_query<-function(filename, querystr, max_mem=8000){

  # first-round, get the max length and the number of lines of the result.
  out =.C("get_size", filename, querystr, as.integer(0), as.integer(0), as.integer(0))
  if(out[[5]][1] == -1 ) return(NULL)  ## error
  str_len = out[[4]][1]
  n=out[[3]][1]
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
  res.table = as.data.frame(do.call("rbind",strsplit(out2[[3]],'\t')),stringsAsFactors=F)
  return (res.table)
}


