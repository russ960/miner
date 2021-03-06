con <- NULL

#' Return cached connection
#' @return connection
#' @keywords internal
mc_connection <- function() {

    if (is.null(con)) {
        stop('First init a connection to the Minecraft Server via the mc_connect function')
    }

    return(con)

}


#' Create a connection to a Minecraft server
#'
#' @param hostname A character string with the hostname or IP address for the
#'    Minecraft Spigot server to which you want to connect.
#' @param port An integer giving the port to use for the connection.
#'
#' @return Nothing returned, the connection is cached within the package namespace.
#'
#' @examples \dontrun{
#' mc_connect()
#' getPlayerIds()
#' mc_close()
#' }
#'
#' @importFrom utils assignInMyNamespace
#' @export
mc_connect <- function(hostname = Sys.getenv("SPIGOT_HOSTNAME", "localhost"), port = Sys.getenv("SPIGOT_PORT", "4711"))
{
    utils::assignInMyNamespace('con',
                        socketConnection(
                            host = hostname, as.integer(port), open = "r+b",
                            encoding = "CP437", blocking = TRUE, timeout = 1))
}


#' Close cached connection to Minecraft server
#'
#' Close the current connection to a Minecraft server.
#'
#' @return None.
#'
#' @examples \dontrun{
#'   mc_connect()
#'   getPlayerIds()
#'   mc_close()
#' }
#'
#' @export
mc_close <- function() {
    close(con)
}


mc_send <- function(text)
{
    if(is.null(text) || text=='') warning("text was empty")
    writeLines(text, con=mc_connection(), useBytes=TRUE)
}


mc_receive <- function()
{
    res <- readLines(mc_connection(), n = 1L, encoding = "CP437")
    if(length(res) == 0) {
        stop("The server returned nothing; the connection may be down.")
    }
    if (length(res) == 1 && res == 'Fail') {
        stop('The server returned an error')
    }
    res
}


# trick seems to be waiting long enough for the response, but not too long
mc_sendreceive <- function(text)
{
    mc_send(text)
    mc_receive()
}

merge_data <- function(text, ...)
{
    dots <- list(...)
    if(is.null(text)) text <- ""

    paste0(text, "(",
           paste(unlist(dots), collapse=","), ")")
}
