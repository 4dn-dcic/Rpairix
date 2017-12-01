#' Print function
#'
#' This function prints out a message and returns the number of characters in the message.
#'
#' @param message a character string (default 'Hello World!') 
#' @param print.message the message is printed if TRUE (default TRUE)
#'
#' @return number of characters in the message.
#' @keywords greeting
#' @export hello
#' @examples
#' hello()
#'
#' hello('hahaha')
#'
#' hello('lalala', FALSE)
#'
hello<-function(message='Hello World!', print.message=TRUE){
  if(print.message==TRUE) print(message)
  return(nchar(message))
}
