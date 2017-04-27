#' Check function on pairix-indexed 2D pairs file.
#'
#' This function allows you to check if a pair of chromosomes exists in a 2D-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param chr1 first chromosome
#' @param chr2 second chromosome
#'
#' @return TRUE if the key exists or FALSE if not. If index loading fails, NULL is returned.
#' @keywords pairix check
#' @export px_exists2
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' chr1 = "chr22"
#' chr2 = "chrX"
#' res = px_exists2(filename, chr1, chr2)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",package="Rpairix")
#' chr1 = "10"
#' chr2 = "20"
#' res = px_exists2(filename, chr1, chr2)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' chr1 = "10"
#' chr2 = "20"
#' res = px_exists2(filename, chr1, chr2)
#' print(res)
#' @useDynLib Rpairix key_exists
px_exists2<-function(filename, chr1, chr2){
  separator= '|'
  key = paste(chr1, separator, chr2, sep="")
  out = .C("key_exists", filename, key, as.integer(0))
  if(out[[3]][1]==-1) { message("Can't open index file"); return(NULL); }
  return(ifelse(out[[3]][1]==1,TRUE,FALSE))
}
