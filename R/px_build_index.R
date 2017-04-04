#' Check function on pairix-indexed pairs file.
#'
#' This function allows you to check if a key (chr for 1D, chr pair for 2D) exists in a pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param preset one of the following strings: 'gff', 'bed', 'sam', 'vcf', 'psltbl' (1D-indexing) or 'pairs', 'merged_nodups', 'old_merged_nodups' (2D-indexing). (default 'pairs')
#' @param force If TRUE, overwrite existing index file. If FALSE, do not overwrite unless the index file is older than the bgzipped file. (default FALSE)
#'
#' @keywords pairix index
#' @export px_build_index
#' @examples
#'
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' px_build_index(filename)
#'
#' @useDynLib Rpairix build_index
px_build_index<-function(filename, preset='pairs', force=FALSE){
  if(!file.exists(filename)) { message("Cannot find input file."); return(-1); }
  out = .C("build_index", filename, preset, force, as.integer(0))
  if(out[[4]][1] == -1) { message("Can't create index."); return(-1); }
  if(out[[4]][1] == -2) { message("Can't recognize preset."); return(-1); }
  if(out[[4]][1] == -3) { message("Was bgzip used to compress this file?"); return(-1); }
  if(out[[4]][1] == -4) { message("The index file exists. Please use force=TRUE to overwrite"); return(-1); }
  return(0);
}

