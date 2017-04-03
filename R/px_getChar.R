#' Test function
#'
#' This function is a test function.
#' @param char_vector a character vector
#'
#' @keywords pairix test
#' @export px_getChar
#' @useDynLib Rpairix getChar
px_getChar<-function(char_vector){
  n=length(char_vector);
  .Call("getChar2", char_vector, n)
  print(n);
}

