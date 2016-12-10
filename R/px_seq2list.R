#' Function to get the list of second chromosomes from a pairix-indexed pairs file.
#'
#' This function allows you to get the list of second chromosomes in a pairix-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#'
#' @keywords pairix query 2D
#' @export px_seq2list
#' @examples
#' filename = "data/merged_nodup.tab.chrblock_sorted.txt.gz"
#' res = px_seq2list(filename)
px_seq2list<-function(filename){
  seqpairs = px_keylist(filename)
  seq2_list = unique(sapply(seqpairs,function(xx)strsplit(xx,'|',fixed=T)[[1]][2]))
  return(sort(seq2_list))
}

