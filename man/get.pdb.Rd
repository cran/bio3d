\name{get.pdb}
\alias{get.pdb}
\title{ Download PDB Coordinate Files }
\description{
  Downloads PDB coordinate files from the RCSB Protein Data Bank.
}
\usage{
get.pdb(ids, path = ".", URLonly=FALSE, overwrite = FALSE, gzip = FALSE, 
     split = FALSE, format = "pdb", verbose = TRUE, ncore = 1, ...)
}
\arguments{
  \item{ids}{ A character vector of one or more 4-letter PDB
    codes/identifiers or 6-letter PDB-ID_Chain-ID of the files to be downloaded, or a \sQuote{blast}
    object containing \sQuote{pdb.id}. }
  \item{path}{ The destination path/directory where files are to be
    written. }
  \item{URLonly}{ logical, if TRUE a character vector containing the URL
    path to the online file is returned and files are not downloaded. If
    FALSE the files are downloaded. }
  \item{overwrite}{ logical, if FALSE the file will not be downloaded if
    it alread exist. }
  \item{gzip}{ logical, if TRUE the gzipped PDB will be downloaded and
    extracted locally. }
  \item{split}{ logical, if TRUE \code{\link{pdbsplit}} funciton will be called to split pdb files
    into separated chains. }
  \item{format}{ format of the data file: \sQuote{pdb} or
    \sQuote{cif} for PDB and mmCIF file formats, respectively. }
  \item{verbose}{ print details of the reading process. }
  \item{ncore}{ number of CPU cores used to do the calculation.
     \code{ncore>1} requires package \sQuote{parallel} installed. }
  \item{\dots}{ extra arguments passed to \code{\link{pdbsplit}} function. }
}
\details{
  This is a basic function to automate file download from the PDB.
}
\value{
  Returns a list of successfully downloaded files. Or optionally if URLonly
  is TRUE a list of URLs for said files.
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
  
  For a description of PDB format (version3.3) see:\cr
  \url{http://www.wwpdb.org/documentation/format33/v3.3.html}.
}
\author{ Barry Grant }
\seealso{ \code{\link{read.pdb}}, \code{\link{write.pdb}},
  \code{\link{atom.select}}, \code{\link{read.fasta.pdb}},
  \code{\link{read.fasta}}, \code{\link{pdbsplit}} }
\examples{
\donttest{
# PDB server connection required - testing excluded

## PDB file paths
get.pdb( c("1poo", "1moo"), URLonly=TRUE )

## These URLs can be used by 'read.pdb'
pdb <- read.pdb( get.pdb("5p21", URL=TRUE) )
summary(pdb)

## Download PDB file
## get.pdb("5p21")
}
}
\keyword{utilities}
