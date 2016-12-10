#' Function to get the list of first chromosomes from a pairix-indexed pairs file.
#'
#' This function allows you to get the list of first chromosomes in a pairix-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#'
#' @keywords pairix query 2D
#' @export px_seq1list
#' @examples
#' filename = "merged_nodup.tab.chrblock_sorted.txt.gz"
#' res = px_seq1list(filename)
px_seq1list<-function(filename){
  seqpairs = px_keylist(filename)
  seq1_list = unique(sapply(seqpairs,function(xx)strsplit(xx,'|',fixed=T)[[1]][1]))
  return(sort(seq1_list))
}
