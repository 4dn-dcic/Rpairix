% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/px_check_1d_vs_2d.R
\name{px_check_1d_vs_2d}
\alias{px_check_1d_vs_2d}
\title{Check function on pairix-indexed pairs file.}
\usage{
px_check_1d_vs_2d(filename)
}
\arguments{
\item{filename}{a pairs file, or a bgzipped text file (sometextfile.gz) with an index file sometextfile.gz.px2 in the same folder.}
}
\value{
integer ! if 1D-indexed, 2 if 2D-indexed, -1 if error.
}
\description{
This function checks whether your pairs file is 1D- or 2D-indexed
}
\examples{

## 2D-indexed file
filename = system.file(".","test_4dn.pairs.gz", package="Rpairix")
res = px_check_1d_vs_2d(filename)
print(res)

## 1D-indexed file
filename = system.file(".","SRR1171591.variants.snp.vqsr.p.vcf.gz", package="Rpairix")
res = px_check_1d_vs_2d(filename)
print(res)

}
\keyword{2D}
\keyword{pairix}
\keyword{query}
