#' Function on pairix-indexed pairs file.
#'
#' This function returns the total line count of a pairs file (equivalent to gunzip -c | wc -l but much faster)
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @return An integer corresponding to total line count, NULL if error.
#'
#' @keywords pairix linecount line count
#' @export px_get_linecount
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' px_get_linecount(filename)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",package="Rpairix")
#' px_get_linecount(filename)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' px_get_linecount(filename)
#'
#' @useDynLib Rpairix Get_linecount
px_get_linecount<-function(filename){
  out = .C("Get_linecount", filename, as.integer(0))
  if(out[[2]][1]==-1) { message("Can't open input file"); return(NULL) }
  return(out[[2]][1])
}
