\name{trim.pdbs}
\alias{trim.pdbs}
\title{ Filter or Trim a PDBs Object }
\description{
  Trim residues and/or filter out structures from a PDBs object. 
}
\usage{
\method{trim}{pdbs}(pdbs, row.inds=NULL, col.inds=NULL, \dots)
}
\arguments{
  \item{pdbs}{ an object of class \code{pdbs} as obtained from
    function \code{pdbaln} or \code{read.fasta.pdb}; a xyz matrix
    containing the cartesian coordinates of C-alpha atoms. }
  \item{row.inds }{ a numeric vector of indices pointing to the PDB
    structures to keep (rows in the \code{pdbs$ali} matrix). }
  \item{col.inds }{ a numeric vector of indices pointing to the
    alignment columns to keep (columns in the \code{pdbs$ali} matrix). } 
  \item{\dots}{ additional arguments passed to and from functions. } 
}
\details{
  Utility function to remove structures, or trim off columns, in a   
  \sQuote{pdbs} object. 
}
\value{
  Returns an updated \sQuote{pdbs} object with the following
  components:
  \item{xyz}{numeric matrix of aligned C-alpha coordinates.}
  \item{resno}{character matrix of aligned residue numbers.}
  \item{b}{numeric matrix of aligned B-factor values.}
  \item{chain}{character matrix of aligned chain identifiers.}
  \item{id}{character vector of PDB sequence/structure names.}
  \item{ali}{character matrix of aligned sequences.}
  \item{call}{ the matched call. }
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
}
\author{ Lars Skjaerven }
\seealso{
  \code{\link{pdbaln}}, \code{\link{gap.inspect}},
  \code{\link{read.fasta}},\code{\link{read.fasta.pdb}},
  \code{\link{trim.pdb}},
}
\examples{
\dontrun{
## Fetch PDB files and split to chain A only PDB files
ids <- c("1a70_A", "1czp_A", "1frd_A", "1fxi_A", "1iue_A", "1pfd_A")
raw.files <- get.pdb(ids, path = "raw_pdbs")
files <- pdbsplit(raw.files, ids, path = "raw_pdbs/split_chain")

## Sequence Alignement, and connectivity check
pdbs <- pdbaln(files)

cons <- inspect.connectivity(pdbs)

## omit files with missing residues
trim.pdbs(pdbs, row.inds=which(cons))
}
}
\keyword{ utilities }