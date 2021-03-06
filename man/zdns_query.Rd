% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zdns-bulk-query.R
\name{zdns_query}
\alias{zdns_query}
\title{Bulk query using zdns}
\usage{
zdns_query(entities, input_file = NULL, query_type = "A", output_file,
  num_nameservers = 3000L, num_retries = 3, num_threads = 500,
  log = TRUE, verbose = 3)
}
\arguments{
\item{entities}{a character vector of entities to resolve}

\item{input_file}{if not \code{NULL}, overrides \code{entities} and this file
will be used as the entities source. It \emph{must} be a plain text
file with one entity to resovle per-line. \code{path.expand()} will
be run on this value.}

\item{query_type}{anything \code{zdns} supports. Presently, one of \code{A}, \code{AAAA},
\code{ANY}, \code{AXFR}, \code{CAA}, \code{CNAME}, \code{DMARC}, \code{MX}, \code{NS}, \code{PTR}, \code{TXT},
\code{SOA}, or \code{SPF} (can be lower-case). Default is \code{A}.}

\item{output_file}{path + file to the JSON output. \code{path.expand()} will be run
on this value.}

\item{num_nameservers}{total number of nameservers to use. They will be randomly
selected from the cached list of valid, public nameservers. It is \emph{highly}
recommended that you refresh this list periodicaly (perhaps daily).}

\item{num_retries}{how many times should \code{zdns} retry query if timeout or
temporary failure? Defaults to \code{3}.}

\item{num_threads}{number of lightweight go threads. Note that the default \code{500} is
smaller than the built-in default of \code{1000}.}

\item{log}{if \code{TRUE} the JSON error log file will be automatically generated and
the location printed to the console. If a length 1 character vector, this
path + file will be used to save the JSON error log. If \code{FALSE} no error
log will be captured.}

\item{verbose}{a value between \code{1} and \code{5} indicating the verbosity level. Defaults
to \code{3}. Set this to \code{1} if you're working inside RStudio or other
environments that can't handle a great deal of console text since
the messages are placed on \code{stdout} when \code{log} equals \code{FALSE}.}
}
\value{
value from the \code{system2()} call to \code{zdns} (invisibly)
}
\description{
Given an entity list and an output file, \code{zdns} will be executed and
JSON output stored in \code{output_file} and an optional \code{log} file
(if specified).
}
\note{
if you specified \code{TRUE} for \code{log} then \emph{you} are responsible for
removing the auto-generated log file.
}
\examples{
\dontrun{
# enumerate top prefixes for a domain

c(
  "www", "mail", "mx", "blog", "ns1", "ns2", "dev", "server", "email",
  "cloud", "api", "support", "smtp", "app", "webmail", "test", "box",
  "m", "admin", "forum", "news", "web", "mail2", "ns", "demo", "my",
  "portal", "shop", "host", "cdn", "git", "vps", "mx1", "mail1",
  "static", "help", "ns3", "beta", "chat", "secure", "staging", "vpn",
  "apps", "server1", "ftp", "crm", "new", "wiki",  "home", "info"
) -> top_common_prefixes

tf <- tempfile(fileext = ".json")

zdns_query(
  sprintf("\%s.rstudio.com", top_common_prefixes),
  query_type = "A",
  num_nameservers = (length(top_common_prefixes) * 2),
  output_file = tf
)

res <- jsonlite::stream_in(file(tf))

found <- which(lengths(res$data$answers) > 0)

do.call(
  rbind.data.frame,
  lapply(found, function(idx) {
    res$data$answers[[idx]]$query_name <- res$name[idx]
    res$data$answers[[idx]]
  })
) -> xdf

xdf <- xdf[,c("query_name", "name", "class", "ttl", "type", "answer")]

knitr::kable(xdf)
}
}
