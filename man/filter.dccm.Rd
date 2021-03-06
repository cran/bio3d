\name{filter.dccm}
\alias{filter.dccm}
\title{ Filter for Cross-correlation Matrices (Cij) }
\description{
  This function builds various cij matrix for correlation network analysis
}
\usage{
  filter.dccm(x, cutoff.cij = NULL, cmap = NULL, xyz = NULL, fac = NULL, 
      cutoff.sims = NULL, collapse = TRUE, extra.filter = NULL, ...)
}
\arguments{
  \item{x}{ A matrix (nXn), a numeric array with 3 dimensions (nXnXm), 
    a list with m cells each containing nXn matrix, or a list with
    \sQuote{all.dccm} component, containing atomic correlation values, 
    where "n" is the number of residues and "m" the number of calculations. 
    The matrix elements should be in between -1 and 1. See \sQuote{dccm} 
    function in bio3d package for further details. }
  \item{cutoff.cij}{ Threshold for each individual correlation value. 
    If NULL, a guessed value will be used. See below for details. }
  \item{cmap}{ logical or numerical matrix indicating the contact map.
    If logical and TRUE, contact map will be calculated with input
    \code{xyz}. } 
  \item{xyz}{ XYZ coordinates, or a \sQuote{pdbs} object obtained from 
    \code{pdbaln} or \code{read.fasta.pdb}, for contact map calculations. }
  \item{fac}{ factor indicating distinct categories of input correlation matrices. }
  \item{cutoff.sims}{ Threshold for the number of simulations with observed correlation
    value above \code{cutoff.cij} for the same residue/atomic pairs. See below for details. }
  \item{collapse}{ logical, if TRUE the mean matrix will be returned. }
  \item{extra.filter}{ Filter to apply in addition to the model chosen. } 
  \item{\dots}{ extra arguments passed to function \code{cmap}. } 
}
\value{
  Returns a matrix of class "dccm" or a 3D array of filtered cross-correlations.
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
}
\author{ Xin-Qiu Yao, Guido Scarabelli & Barry Grant }
\details{ 
     If cmap is TRUE or provided a numerical matrix, the function inspects
     a set of cross-correlation matrices, or DCCM, and decides edges for 
     correlation network analysis based on:

        1. min(abs(cij)) >= cutoff.cij, or
        2. max(abs(cij)) >= cutoff.cij && residues contact each other 
           based on results from \code{cmap}.

     Otherwise, the function filters DCCMs with \code{cutoff.cij} and 
     return the mean of correlations present in at least 
     \code{cutoff.sims} calculated matrices.

     An internally guessed \code{cuoff.cij} is used if \code{cutoff.cij=NULL} is provided. 
     By default, the cutoff is determined by keeping 5\% of all residue pairs connected. 
}
\seealso{
   \code{\link{cna}}, \code{\link{dccm}}, \code{\link{dccm.nma}}, \code{\link{dccm.xyz}},
   \code{\link{cmap}}, \code{\link{plot.dccm}} 
}
\examples{

\dontrun{

# Example of transducin
attach(transducin)

gaps.pos <- gap.inspect(pdbs$xyz)
modes <- nma.pdbs(pdbs, ncore=NULL)
dccms <- dccm.enma(modes, ncore=NULL)

cij <- filter.dccm(dccms, xyz=pdbs)

# Example protein kinase
# Select Protein Kinase PDB IDs
ids <- c("4b7t_A", "2exm_A", "1opj_A", "4jaj_A", "1a9u_A",
                 "1tki_A", "1csn_A", "1lp4_A")

# Download and split by chain ID
files <- get.pdb(ids, path = "raw_pdbs", split=TRUE)

# Alignment of structures
pdbs <- pdbaln(files) # Sequence identity
summary(c(seqidentity(pdbs)))

# NMA on all structures
modes <- nma.pdbs(pdbs, ncore=NULL)

# Calculate correlation matrices for each structure
cij <- dccm(modes)

# Set DCCM plot panel names for combined figure
dimnames(cij$all.dccm) = list(NULL, NULL, ids)
plot.dccm(cij$all.dccm)

# Filter to display only correlations present in all structures
cij.all <- filter.dccm(cij, cutoff.sims = 8, cutoff.cij = 0)
plot.dccm(cij.all, main = "Consensus Residue Cross Correlation")

detach(transducin)
}

}
\keyword{analysis}
