#' Indexing function on bgzipped pairs file.
#'
#' This function creates a pairix (px2) index a bgzipped text file. Either a preset or a set of custom parameters (column indices, comment_char, line_skip) must be specified.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param preset one of the following strings: 'gff', 'bed', 'sam', 'vcf', 'psltbl' (1D-indexing) or 'pairs', 'merged_nodups', 'old_merged_nodups' (2D-indexing). If preset is '', at least some of the custom parameters must be given instead (sc, bc, ec, sc2, bc2, ec2, delimiter, comment_char, line_skip). (default '')
#' @param sc first sequence (chromosome) column index (1-based). Zero (0) means not specified. If preset is given, preset overrides sc. If preset is not given, this one is required. (default 0)
#' @param bc first start position column index (1-based). Zero (0) means not specified. If preset is given, preset overrides bc. If preset is not given, this one is required. (default 0)
#' @param ec first end position column index (1-based). Zero (0) means not specified. If preset is given, preset overrides ec. (default 0)
#' @param sc2 second sequence (chromosome) column index (1-based). Zero (0) means not specified. If preset is given, preset overrides sc2. If sc, bc are specified but not sc2 and bc2, it is 1D-indexed. (default 0)
#' @param bc2 second start position column index (1-based). Zero (0) means not specified. If preset is given, preset overrides bc2. (default 0)
#' @param ec2 second end position column index (1-based). Zero (0) means not specified. If preset is given, preset overrides ec2. (default 0)
#' @param delimiter delimiter (e.g. '\t' or ' ') (default '\t'). If preset is given, preset overrides delimiter.
#' @param comment_char comment character. Lines beginning with this character are skipped when creating an index. If preset is given, preset overrides comment_char (default '#')
#' @param line_skip number of lines to skip in the beginning. (default 0) 
#' @param force If TRUE, overwrite existing index file. If FALSE, do not overwrite unless the index file is older than the bgzipped file. (default FALSE)
#'
#' @keywords pairix index
#' @export px_build_index
#' @examples
#'
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' px_build_index(filename, 'pairs', force=TRUE)
#' px_build_index(filename, sc=2, bc=3, ec=3, sc2=4, bc2=5, ec2=5, force=TRUE)
#'
#' @useDynLib Rpairix build_index
px_build_index<-function(filename, preset='', sc=0, bc=0, ec=0, sc2=0, bc2=0, ec2=0, delimiter='\t', comment_char='#', line_skip=0, force=FALSE){
  if(!file.exists(filename)) { message("Cannot find input file."); return(-1); }
  sc=as.integer(sc)
  bc=as.integer(bc)
  ec=as.integer(ec)
  sc2=as.integer(sc2)
  bc2=as.integer(bc2)
  ec2=as.integer(ec2)
  line_skip=as.integer(line_skip)
  out = .C("build_index", filename, preset, sc, bc, ec, sc2, bc2, ec2, delimiter, comment_char, line_skip, force, as.integer(0))
  if(out[[13]][1] == -1) { message("Can't create index."); return(-1); }
  if(out[[13]][1] == -2) { message("Can't recognize preset."); return(-1); }
  if(out[[13]][1] == -3) { message("Was bgzip used to compress this file?"); return(-1); }
  if(out[[13]][1] == -4) { message("The index file exists. Please use force=TRUE to overwrite"); return(-1); }
  return(0);
}

