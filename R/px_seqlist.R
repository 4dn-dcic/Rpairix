#' Function to get the list of chromosomes from a pairix-indexed pairs file.
#'
#' This function allows you to get the list of chromosomes in a pairix-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#'
#' @keywords pairix query 2D
#' @export px_seqlist
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' res = px_seqlist(filename)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",package="Rpairix")
#' res = px_seqlist(filename)
#' print(res)
px_seqlist<-function(filename){
  seqpairs = px_keylist(filename)
  seq1_list = unique(sapply(seqpairs,function(xx)strsplit(xx,'|',fixed=T)[[1]][1]))
  seq2_list = unique(sapply(seqpairs,function(xx)strsplit(xx,'|',fixed=T)[[1]][2]))
  seq_list = unique(c(seq1_list, seq2_list))
  return(sort(seq_list))
}
