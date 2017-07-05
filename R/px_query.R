#' Query pairix-indexed pairs file.
#'
#' This function allows you to query a 2D range in a pairix-indexed pairs file using strings or GenomicRanges-related objects.
#'
#' @param filename a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.
#' @param query One of three types: (1) a character vector containing a set of pairs of genomic coordinates in 1-based "chr1:start1-end1|chr2:start2-end2" format. start-end can be omitted (e.g. "chr1:start1-end1|chr2" or "chr1|chr2"); (2) A GInteractions object from the package "InteractionSet"; (3) A GRangesList composed of two GRanges objects of identical length (first pairs, second pairs), from the package "GenomicRanges".
#' @param max_mem the total string length allowed for the result. If the size of the output exceeds this number, the function will return NULL and print out a memory error. Default 100,000,000.
#' @param stringsAsFactors the stringsAsFactors parameter for the data frame returned. Default False.
#' @param linecount.only If TRUE, the function returns an integer corresponding to the number of output lines instead of the actual query result. (default FALSE) 
#' @param autoflip If TRUE, the function will rerun on a flipped query (mate1 and mate2 swapped) if the original query results in an empty output. (default FALSE). If linecount.only option is used in combination with autoflip, the result count is on the flipped query in case the query gets flipped.
#'
#' @return data frame containing the query result. Column names are added if indexing was done with a pairs preset.
#' @keywords pairix query 2D GenomicRanges GInteractions
#' @import InteractionSet GenomicRanges
#' @details This function is compatible with Bioconductor packages InteractionSet and GenomicRanges.
#' @export px_query
#' @examples
#' 
#' ##### -- query using strings -- ######
#' 
#' ## 2D-indexed file
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' query = c("chr10|chr20","chr22|chr22")
#' res = px_query(filename, query)
#' print(res)
#'
#' n = px_query(filename, query, linecount.only=TRUE)
#' print(n) 
#'
#' query = "chr20|chr10"
#' res = px_query(filename, query, autoflip=TRUE)
#' print(res)
#'
#' ## wild card query
#' query = "chr21|*"
#' res = px_query(filename, query, autoflip=TRUE)
#' print(res)
#'
#' query = "*|chr21"
#' res = px_query(filename, query, autoflip=TRUE)
#' print(res)
#'
#' ## the following attempts will return NULL and give you a warning message.
#' query = "chr20"
#' res = px_query(filename, query, autoflip=TRUE)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz", package="Rpairix")
#' query = "10:1-1000000|20"
#' res = px_query(filename, query)
#' print(res)
#'
#' ## the following attempts will return NULL and give you a warning message.
#' res = px_query(filename, query, autoflip=TRUE)
#' print(res)
#'
#' filename = system.file(".","merged_nodups.space.chrblock_sorted.subsample1.txt.gz",
#' package="Rpairix")
#' query = "10:1-1000000|20"
#' res = px_query(filename, query)
#' print(res)
#'
#' ## 1D-indexed file
#' filename = system.file(".","SRR1171591.variants.snp.vqsr.p.vcf.gz", package="Rpairix")
#' query = 'chr10|5000000-20000000'
#' res = px_query(filename, query)
#' print(res)
#' 
#' ## the following attempts will return NULL and give you a warning message.
#' query = 'chr10|chr20'
#' res = px_query(filename, query)
#' print(res)
#' 
#' 
#' ##### -- query using GenomicRanges-related objects -- #####
#' 
#' filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
#' 
#' # create GRangesList
#' library(GenomicRanges)
#' gr <- GRanges(
#'   seqnames = Rle(c("chr10", "chr20", "chr21", "chr22"), c(1, 2, 1, 2)),
#'   ranges = IRanges((0:5*1000000)+1, end = (0:5*1000000)+13000000))
#' grl <- split(gr, rep(1:2,3))
#' grl
#' 
#' # create GInteractions
#' library(InteractionSet)
#' gi <- GInteractions(grl[[1]],grl[[2]])
#' gi
#' 
#' # query with GInteractions
#' res = px_query(filename,query=gi)
#' print(res)
#' 
#' # query with GRangesList
#' res = px_query(filename,query=grl)
#' print(res)
#'
#' @useDynLib Rpairix get_size get_lines check_1d_vs_2d
px_query<-function(filename, query, max_mem=100000000, stringsAsFactors=FALSE, linecount.only=FALSE, autoflip=FALSE){

  # -- helper function -- #
  df_to_querystr <- function(qdf){
    # expects presorted df (columns ordered: seqnames1,start1,end1,seqnames2,start2,end2)
    querystr <- paste0(qdf[,1],":",qdf[,2],"-",qdf[,3],"|",qdf[,4],":",qdf[,5],"-",qdf[,6])
    return(querystr)
  }
  
  # -- produce querystr -- #
  if(class(query)=="character"){
    querystr <- query
  } else if (class(query)=="GInteractions"){
    # -- produce querystr from GInteractions obj -- #
    # convert
    qdf <- as.data.frame(query)
    qdf <- qdf[,c("seqnames1","start1","end1","seqnames2","start2","end2")]
    querystr <- df_to_querystr(qdf)
    rm(qdf)
  } else if (class(query)=="GRangesList"){
    # -- produce querystr from two identical-length, paired GRanges objects in a GRangesList-- #
    # test lengths
    if(length(query) != 2) stop("GRangesList must be composed of two GRanges objects.")
    if(diff(sapply(query,length)) != 0) {
      stop("Paired GRanges objects in the GRangesList must be of identical length.")
    }
    # convert
    grldf <- lapply(query,as.data.frame)
    names(grldf[[2]]) <- sub("$","2",names(grldf[[2]]))
    grldf <- cbind(grldf[[1]],grldf[[2]])
    grldf <- grldf[,c("seqnames","start","end","seqnames2","start2","end2")]
    querystr <- df_to_querystr(grldf)
    rm(grldf)
  } else {
    stop("query must be of class 'character', 'GInteractions', or 'GRangesList'.")
  }
  rm(query)

  # sanity check for 2D query on 1D index.
  ind_dim = .C("check_1d_vs_2d", filename, as.integer(0))
  if(ind_dim[[2]][1]==1 && length(grep('|',querystr, fixed=TRUE))>0) { message("2D query on 1D-indexed file?"); return(NULL) }

  # sanity check for autoflip on 1D query
  if(autoflip==TRUE && length(grep('|',querystr, fixed=TRUE))==0) { message("autoflip works only for 2D query."); return(NULL) }

  # first-round, get the max length and the number of lines of the result.
  out = .Call("get_size", filename, querystr, length(querystr))

  if(out[3] == -1 ) { message("Can't open input file"); return(NULL) }  ## error
  n=out[1]
  if(n==0 && autoflip==TRUE) {
    querystr=paste(strsplit(querystr,'|',fixed=TRUE)[[1]][c(2,1)],collapse="|")  ## flip mate1 and mate2
    out = .Call("get_size", filename, querystr, length(querystr))
    if(out[3] == -1 ) { message("Can't open input file"); return(NULL) }  ## error
    n=out[1]
    if(linecount.only == TRUE) return(n)
  }
  if(linecount.only == TRUE) return(n)

  str_len = out[2]
  total_size = str_len * n
  if(total_size > max_mem) {
     log = paste("not enough memory: Total length of the result to be stored is",total_size,sep=" ")
     message(log)
     return(NULL)
  }

  # second-round, actually get the lines from the file
  result_str = rep(paste(rep("a",str_len),collapse=''),n)
  out2 =.Call("get_lines", filename , querystr, length(querystr), n) 

  if(out2[[2]][1] == -1) return(NULL)  ## error

  ## tabularize
  ##res.table = as.data.frame(do.call("rbind",strsplit(out2[[1]],'\t')),stringsAsFactors=stringsAsFactors)
  res.table = as.data.frame(do.call("rbind",out2[[1]]),stringsAsFactors=stringsAsFactors)
  cols = px_get_column_names(filename)
  if(!is.null(cols) && length(cols)==ncol(res.table)) colnames(res.table)=cols; 

  return (res.table)
}


