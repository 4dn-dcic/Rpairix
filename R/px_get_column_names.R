#' Column name retrival function on pairix-indexed pairs file.
#'
#' This function returns a vector of column names for a pairs format.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#'
#' @keywords pairix names
#' @export px_get_column_names
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' cols = px_get_column_names(filename)
#' print(cols)
#' @useDynLib Rpairix get_column_names
px_get_column_names<-function(filename){
  out = .Call("get_column_names", filename)
  if(!is.null(out)) { cols=strsplit(out, ' ')[[1]]; return(cols[2:length(cols)]); } else { return(NULL); }
}
