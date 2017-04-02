#' Function on pairix-indexed pairs file.
#'
#' This function returns the 1-based column index of mate1 startpos in a pairs file. 
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @return An integer corresponding to 1-based column index of mate1 startpos, NULL if error.
#'
#' @keywords pairix column
#' @export px_startpos1_col
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' res = px_startpos1_col(filename)
#' print(res)
#'
#' filename = system.file(".","merged_nodup.tab.chrblock_sorted.txt.gz",package="Rpairix")
#' res = px_startpos1_col(filename)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' res = px_startpos1_col(filename)
#' print(res)
#' @useDynLib Rpairix get_startpos1_col
px_startpos1_col<-function(filename){
  out = .C("get_startpos1_col", filename, as.integer(0))
  if(out[[2]][1]==-1) { message("Can't open input file"); return(NULL) }
  return(out[[2]][1])
}
