#' Query function on pairix-indexed pairs file.
#'
#' This function allows you to query a 2D range in a pairix-indexed pairs file from several query types.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param queryobj One of three types: (1) a character vector containing a set of pairs of genomic coordinates in "chr1:start1-end1|chr2:start2-end2" format. start-end can be omitted (e.g. "chr1:start1-end1|chr2" or "chr1|chr2"); (2) A GInteractions object from the package "InteractionSet"; (3) A GRangesList composed of two GRanges objects of identical length (first pairs, second pairs).
#' @param objtype A string the class of the 'queryobj' object: (1) "str"; (2) "GInteractions"; (3) "GRangesList"
#' @param ... Any of the other parameters from px_query(), such as max_mem, stringsAsFactors, linecount.only, autoflip
#'
#' @return data frame containing the query result. Column names are added if indexing was done with a pairs preset.
#' @keywords pairix query 2D
#' @export px_query
#' @examples
#' 
#' ## 2D-indexed file
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' querystr = c("chr10|chr20","chr22|chr22")
#' res = px_query(filename, querystr)
#' print(res)
#'
#' n = px_query(filename, querystr, linecount.only=TRUE)
#' print(n) 
#'
#' querystr = "chr20|chr10"
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' ## wild card query
#' querystr = "chr21|*"
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' querystr = "*|chr21"
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' ## the following attempts will return NULL and give you a warning message.
#' querystr = "chr20"
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz", package="Rpairix")
#' querystr = "10:1-1000000|20"
#' res = px_query(filename, querystr)
#' print(res)
#'
#' ## the following attempts will return NULL and give you a warning message.
#' res = px_query(filename, querystr, autoflip=TRUE)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' querystr = "10:1-1000000|20"
#' res = px_query(filename, querystr)
#' print(res)
#'
#' ## 1D-indexed file
#' filename = system.file(".","SRR1171591.variants.snp.vqsr.p.vcf.gz", package="Rpairix")
#' querystr = 'chr10|5000000-20000000'
#' res = px_query(filename, querystr)
#' print(res)
#' 
#' ## the following attempts will return NULL and give you a warning message.
#' querystr = 'chr10|chr20'
#' res = px_query(filename, querystr)
#' print(res)
#'
#' @useDynLib Rpairix get_size get_lines check_1d_vs_2d
px_query2 <- function(filename, queryobj, objtype = "str", ...){
  
  # -- helper function -- #
  df_to_querystr <- function(qdf){
    # takes presorted df (columns ordered: seqnames1,start1,end1,seqnames2,start2,end2) and converts to querystr
    querystr <- rep(NA_character_,nrow(qdf))
    for(i in 1:nrow(qdf)){
      q1 <- qdf[i,]
      querystr[i] <- paste0(q1[1],":",q1[2],"-",q1[3],"|",q1[4],":",q1[5],"-",q1[6])
    }
    return(querystr)
  }
  
  # -- produce querystr -- #
  if(objtype=="str"){
    querystr <- queryobj
  } else if (objtype=="GInteractions"){
    # produce querystr from GInteractions obj
    library(InteractionSet) # may not be necessary
    qdf <- as.data.frame(queryobj)
    qdf <- qdf[,c("seqnames1","start1","end1","seqnames2","start2","end2")]
    querystr <- df_to_querystr(qdf)
    # note: anchors(queryobj) would produce a two-element GRangesList, which might be handled identically to the GRangesList below
  } else if (objtype=="GRangesList"){
    # roduce querystr from list of two identical-length, paired GRanges objects
    library(GenomicRanges)
    grldf <- lapply(queryobj,as.data.frame)
    names(grldf[[2]]) <- sub("$","2",names(grldf[[2]]))
    grldf <- cbind(grldf[[1]],grldf[[2]])
    grldf <- grldf[,c("seqnames","start","end","seqnames2","start2","end2")]
    querystr <- df_to_querystr(grldf)
  } else {
    stop("objtype is not specified appropriately: must be 'str', 'GInteractions', or 'GRangesList'.")
  }
  
  return(px_query(filename=filename,querystr=querystr,...))
  
  ## TODO: confirm these are all appropriately one-based or zero-based.
  ## TODO: consider adding testing/object constraints (stopifnot)
  ## TODO: clean up code, check efficiency.
  
}


