#' Check function on pairix-indexed pairs file.
#'
#' This function checks whether your pairs file is 1D- or 2D-indexed
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @return integer ! if 1D-indexed, 2 if 2D-indexed, -1 if error.
#'
#' @keywords pairix query 2D
#' @export px_check_1d_vs_2d
#' @examples
#' 
#' ## 2D-indexed file
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' res = px_check_1d_vs_2d(filename)
#' print(res)
#'
#' ## 1D-indexed file
#' filename = system.file(".","SRR1171591.variants.snp.vqsr.p.vcf.gz", package="Rpairix")
#' res = px_check_1d_vs_2d(filename)
#' print(res)
#'
#' @useDynLib Rpairix check_1d_vs_2d
px_check_1d_vs_2d<-function(filename){
  ind_dim = .C("check_1d_vs_2d", filename, as.integer(0))
  if(ind_dim[[2]][1]==-1) message("Can't open input file")
  return(ind_dim[[2]][1])
}
