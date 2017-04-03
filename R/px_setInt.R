#' Test function
#'
#' This function is a test function.
#'
#' @keywords pairix test
#' @export px_setInt
#' @useDynLib Rpairix setInt
px_setInt<-function(){
  return( .Call("setInt") )
}

