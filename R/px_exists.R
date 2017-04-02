#' Check function on pairix-indexed pairs file.
#'
#' This function allows you to check if a key (chr for 1D, chr pair for 2D) exists in a pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param key a pair of chromosomes in the query string format (e.g. "chr1|chr2"), or a chromosome for a 1D-indexed pairs file (e.g. "chr1"). 
#'
#' @keywords pairix check
#' @export px_exists
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' key = "chrX|chrX"
#' res = px_exists(filename, key)
#' print(res)
#'
#' filename = system.file(".","merged_nodup.tab.chrblock_sorted.txt.gz",package="Rpairix")
#' key = "10|20"
#' res = px_exists(filename, key)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' key = "10|20"
#' res = px_exists(filename, key)
#' print(res)
#' @useDynLib Rpairix key_exists
px_exists<-function(filename, key){
  out = .C("key_exists", filename, key, as.integer(0))
  return(out[[3]][1])
}
