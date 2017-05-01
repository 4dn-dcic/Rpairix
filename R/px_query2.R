#' Query function on pairix-indexed pairs file.
#'
#' This function allows you to query a 2D range in a pairix-indexed pairs file from several query types.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param queryobj One of three types: (1) a character vector containing a set of pairs of genomic coordinates in 1-based "chr1:start1-end1|chr2:start2-end2" format. start-end can be omitted (e.g. "chr1:start1-end1|chr2" or "chr1|chr2"); (2) A GInteractions object from the package "InteractionSet"; (3) A GRangesList composed of two GRanges objects of identical length (first pairs, second pairs).
#' @param ... Any of the other parameters from px_query(), such as max_mem, stringsAsFactors, linecount.only, autoflip.
#'
#' @return data frame containing the query result. Column names are added if indexing was done with a pairs preset.
#' @keywords pairix query 2D GenomicRanges GInteractions
#' @export px_query2
#' @examples
#' 
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' 
#' # -- construct query objects. -- #
#' 
#' # GRangesList
#' library(GenomicRanges)
#' gr <- GRanges(
#'   seqnames = Rle(c("chr10", "chr20", "chr21", "chr22"), c(1, 2, 1, 2)),
#'   ranges = IRanges((0:5*1000000)+1, end = (0:5*1000000)+13000000))
#' grl <- split(gr, rep(1:2,3))
#' grl
#' 
#' # GInteractions
#' library(InteractionSet)
#' gi <- GInteractions(grl[[1]],grl[[2]])
#' gi
#' 
#' # -- query -- #
#' 
#' # with GInteractions
#' res = px_query2(filename,queryobj=gi)
#' print(res)
#' 
#' # with GRangesList
#' res = px_query2(filename,queryobj=grl)
#' print(res)
#'
#' @useDynLib Rpairix get_size get_lines check_1d_vs_2d
px_query2 <- function(filename, queryobj, ...){
  
  # -- helper function -- #
  df_to_querystr <- function(qdf){
    # expects presorted df (columns ordered: seqnames1,start1,end1,seqnames2,start2,end2), converts to querystr
    querystr <- paste0(qdf[,1],":",qdf[,2],"-",qdf[,3],"|",qdf[,4],":",qdf[,5],"-",qdf[,6])
    return(querystr)
  }
  
  # -- produce querystr -- #
  if(class(queryobj)=="character"){
    querystr <- queryobj
  } else if (class(queryobj)=="GInteractions"){
    # -- produce querystr from GInteractions obj -- #
    library(InteractionSet)
    # convert
    qdf <- as.data.frame(queryobj)
    qdf <- qdf[,c("seqnames1","start1","end1","seqnames2","start2","end2")]
    querystr <- df_to_querystr(qdf)
    # note: anchors(queryobj) would produce a two-element GRangesList, which might be handled identically to the GRangesList below, and would simplify this function.
  } else if (class(queryobj)=="GRangesList"){
    # -- produce querystr from list of two identical-length, paired GRanges objects in a GRangesList-- #
    library(GenomicRanges)
    # test lengths
    if(length(queryobj) != 2) stop("GRangesList must be composed of two GRanges objects.")
    if(diff(sapply(queryobj,length)) != 0) stop("Paired GRanges objects in the GRangesList must be of identical length.")
    # convert
    grldf <- lapply(queryobj,as.data.frame)
    names(grldf[[2]]) <- sub("$","2",names(grldf[[2]]))
    grldf <- cbind(grldf[[1]],grldf[[2]])
    grldf <- grldf[,c("seqnames","start","end","seqnames2","start2","end2")]
    querystr <- df_to_querystr(grldf)
  } else {
    stop("queryobj must be of class 'character', 'GInteractions', or 'GRangesList'.")
  }
  
  cat("Querying pairix with string(s) (showing only first five):","\n")
  print(head(querystr))
  return(px_query(filename=filename,querystr=querystr,...))
  
}



