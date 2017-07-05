#' Column name retrival function on pairix-indexed pairs file.
#'
#' This function returns a vector of column names for a pairs format.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#'
#' @keywords pairix names
#' @export px_colnames
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' cols = px_colnames(filename)
#' print(cols)
px_colnames<-function(filename){ 
  px_get_column_names(filename)
}
