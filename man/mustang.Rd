\name{mustang}
\alias{mustang}
\title{ Structure-based Sequence Alignment with MUSTANG }
\description{
  Create a multiple sequence alignment from a bunch of PDB files.
}
\usage{
mustang(files, exefile="mustang", outfile="aln.mustang.fa",
        cleanpdb=FALSE, cleandir="mustangpdbs", verbose=TRUE)  
}
\arguments{
  \item{files}{ a character vector of PDB file names. }
  \item{exefile}{ file path to the \sQuote{MUSTANG} program on your system (i.e.
    how is \sQuote{MUSTANG} invoked). }
  \item{outfile}{ name of \sQuote{FASTA} output file to which alignment
    should be written. }
  \item{cleanpdb}{ logical, if TRUE iterate over the PDB files and map
    non-standard residues to standard residues (e.g. SEP->SER..) to
    produce \sQuote{clean} PDB files. }
  \item{cleandir}{ character string specifying the directory in which
    the \sQuote{clean} PDB files should be written. }
  \item{verbose}{ logical, if TRUE \sQuote{MUSTANG} warning and error
    messages are printed. } 
}
\details{
  Structure-based sequence alignment with \sQuote{MUSTANG} attempts to
  arrange and align the sequences of proteins based on their 3D
  structure.
  
  This function calls the \sQuote{MUSTANG} program, to perform a multiple
  structure alignment, which MUST BE INSTALLED on your system and in the
  search path for executables.

  Note that non-standard residues are mapped to \dQuote{Z} in
  MUSTANG. As a workaround the bio3d \sQuote{mustang} function will
  attempt to map any non-standard residues to standard residues
  (e.g. SEP->SER, etc). To avoid this behaviour use
  \sQuote{cleanpdb=FALSE}.  
  
}
\value{
  A list with two components:
  \item{ali}{ an alignment character matrix with a row per sequence and
    a column per equivalent aminoacid. }
  \item{ids}{ sequence names as identifers.}
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
  
  \sQuote{MUSTANG} is the work of Konagurthu et al:
  Konagurthu, A.S. et al. (2006) \emph{Proteins} \bold{64}(3):559--74.
  
  More details of the \sQuote{MUSTANG} algorithm, along with download and
  installation instructions can be obtained from:\cr
  \url{https://lcb.infotech.monash.edu/mustang/}.
}
\author{ Lars Skjaerven }
\note{
  A system call is made to the \sQuote{MUSTANG} program, which must be
  installed on your system and in the search path for executables.
}
\seealso{ \code{\link{read.fasta}}, \code{\link{read.fasta.pdb}},
  \code{\link{pdbaln}}, \code{\link{plot.fasta}},
  \code{\link{seqaln}}
}
\examples{
\dontrun{

if(!check.utility('mustang')) {
   message('Need MUSTANG installed to run this example')
} else {

## Fetch PDB files and split to chain A only PDB files
ids <- c("1a70_A", "1czp_A", "1frd_A")
files <- get.pdb(ids, split = TRUE, path = tempdir())

##-- Or, read a folder/directory of existing PDB files
#pdb.path <- "my_dir_of_pdbs"
#files  <- list.files(path=pdb.path ,
#                     pattern=".pdb",
#                     full.names=TRUE)

##-- Align these PDB sequences
aln <- mustang(files)

##-- Read Aligned PDBs storing coordinate data
pdbs <- read.fasta.pdb(aln) 

}
}
}
\keyword{ utilities }
