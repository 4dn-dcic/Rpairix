#' Function to get key list from a pairix-indexed pairs file.
#'
#' This function allows you to get the list of keys (chromosome pairs) in a pairix-indexed pairs file.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#'
#' @keywords pairix query 2D
#' @export px_keylist
#' @examples
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' res = px_keylist(filename)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",package="Rpairix")
#' res = px_keylist(filename)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' res = px_keylist(filename)
#' print(res)
#'
#' @useDynLib Rpairix get_keylist_size get_keylist
px_keylist<-function(filename){
   # first-round, get the max length and the number of items in the key list.
   out = .C("get_keylist_size", filename, as.integer(0), as.integer(0), as.integer(0))
   if(out[[4]][1] == -1) return(NULL)   ## error
   max_key_len = out[[3]][1]
   n = out[[2]][1]

   # second-round, get the key list.
   result_str = rep(paste(rep("a",max_key_len),collapse=''),n)
   out = .C("get_keylist", filename, result_str, as.integer(0))
   if(out[[3]][1] == -1) return(NULL)   ## error

   return(out[[2]])
}

