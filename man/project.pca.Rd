\name{project.pca}
\alias{project.pca}
\alias{z2xyz.pca}
\alias{xyz2z.pca}
\title{ Project Data onto Principal Components }
\description{
  Projects data onto principal components.
}
\usage{
project.pca(data, pca, angular = FALSE, fit = FALSE, ...)
z2xyz.pca(z.coord, pca)
xyz2z.pca(xyz.coord, pca)
}
\arguments{
  \item{data}{ a numeric vector or row-wise matrix of data to be projected. }
  \item{pca}{ an object of class \code{"pca"} as obtained from
    functions \code{pca.xyz} or \code{pca.tor}. }
  \item{angular}{ logical, if TRUE the data to be projected is treated
    as torsion angle data. }
  \item{fit}{ logical, if TRUE the data is first fitted to \code{pca$mean}. }
  \item{\dots}{ other parameters for \code{\link{fit.xyz}}. }
  \item{xyz.coord}{ a numeric vector or row-wise matrix of data to be projected. }
  \item{z.coord}{ a numeric vector or row-wise matrix of PC scores
    (i.e. the z-scores which are centered and rotated versions of the
    origional data projected onto the PCs) for conversion to xyz coordinates. }
}
\value{
  A numeric vector or matrix of projected PC scores.
}
\references{
  Grant, B.J. et al. (2006) \emph{Bioinformatics} \bold{22}, 2695--2696.
}
\author{ Karim ElSawy and Barry Grant}
\seealso{ \code{\link{pca.xyz}}, \code{\link{pca.tor}}, \code{\link{fit.xyz}} }
\examples{
\dontrun{
attach(transducin)

gaps.pos <- gap.inspect(pdbs$xyz)

#-- Do PCA without structures 2 and 7
pc.xray <- pca.xyz(pdbs$xyz[-c(2,7), gaps.pos$f.inds])

#-- Project structures 2 and 7 onto the PC space
d <- project.pca(pdbs$xyz[c(2,7), gaps.pos$f.inds], pc.xray)

plot(pc.xray$z[,1], pc.xray$z[,2],col="gray")
points(d[,1],d[,2], col="red")

detach(transducin)
}
}
\keyword{ utilities }
