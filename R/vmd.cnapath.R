vmd.cnapath <- function(x, pdb, out.prefix = "vmd.cnapath", spline = FALSE, 
        colors = c("blue", "red"), launch = FALSE, exefile=NULL, mag=1.0, ...) {

   if(!inherits(x, "cnapath")) {
      if(is.list(x) && inherits(x[[1]], "cnapath")) {
         if(length(x)==1) {
            x <- x[[1]]
         }
         else {
            x2 <- do.call(mapply, c(list("c"), x, list(SIMPLIFY=FALSE)))
            x2$grp <- rep(1:length(x), times=sapply(x, function(x) length(x$path)))
            class(x2) <- "cnapath"
            x <- x2
         }
      }
      else {
         stop("Input x is not a (or a list of) 'cnapath' object(s)")
      }
   }

   # Check colors
   if(is.character(colors)) {
      cols <- colors
   } 
   else {
      if(length(colors) == 1 && is.numeric(colors))
         cols <- vmd_colors()[colors + 1]
      else
         stop("colors should be a character vector or an integer indicating a VMD color ID")
   }
   if(!is.null(x$grp)) {
      if(length(cols) != max(x$grp)) {
        stop("Color length does not match input x")
      }
      cols <- lapply(cols, colorRamp)
   }
   else {
      cols <- colorRamp(cols)
   }

   file = paste(out.prefix, ".vmd", sep="")
   pdbfile = paste(out.prefix, ".pdb", sep="")

   res <- unique(unlist(x$path))
   ind.source <- match(x$path[[1]][1], res)
   ind.sink <- match(x$path[[1]][length(x$path[[1]])], res)

   ca.inds <- atom.select(pdb, elety="CA", verbose = FALSE)
   res.pdb <- pdb$atom[ca.inds$atom[res], "resno"] 
   chain.pdb <- pdb$atom[ca.inds$atom[res], "chain"]
   names(res.pdb) <- chain.pdb

   # make VMD atom selection string
   .vmd.atomselect <- function(res) {
      if(any(is.na(names(res))))
          return(paste("resid", paste(res, collapse=" ")))
      else {
         res <- res[order(names(res))]
         inds <- bounds(names(res), dup.inds=TRUE)
         string <- NULL
         for(i in 1:nrow(inds)) {
            string <- c(string, paste("chain", names(res)[inds[i, "start"]],
               "and resid", paste(res[inds[i, "start"]:inds[i, "end"]], collapse=" ")))
         }   
         return(paste(string, collapse=" or "))
      }
   }
 
   # Draw molecular structures
   cat("mol new ", pdbfile, " type pdb first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all
mol delrep 0 top
mol representation NewCartoon 0.300000 10.000000 4.100000 0
mol color colorID 8
mol selection {all}
mol material Opaque
mol addrep top
mol representation Licorice 0.300000 10.000000 10.000000
mol color name
mol selection {(", .vmd.atomselect(res.pdb[c(ind.source, ind.sink)]), ")} 
mol material Opaque
mol addrep top 
mol representation VDW 0.4 10
mol color colorID 2
mol selection {(", .vmd.atomselect(res.pdb), ") and name CA}
mol material Opaque
mol addrep top
", file=file)

   # Draw paths 
   cat("\n# start drawing suboptimal paths\n", file=file, append=TRUE)

   rad <- function(r, rmin, rmax, radmin = 0.01, radmax = 0.5) {
      (rmax - r) / (rmax - rmin) * (radmax - radmin) + radmin
   }
   rmin <- min(x$dist)
   rmax <- max(x$dist)
  
   # turn off display update for speed up
   cat("display update off\n", file=file, append=TRUE)

   # find start color id for new colors 
   cat("set color_start [colorinfo num]\n", file=file, append=TRUE)

   if(!spline) {
      col.mat <- array(list(), dim=c(length(res), length(res)))
      conn <- matrix(0, length(res), length(res))
      rr <- conn
      for(j in 1:length(x$path)) {
         y = x$path[[j]]
         for(i in 1:(length(y)-1)) {
            i1 = match(y[i], res)
            i2 = match(y[i+1], res)
            if(conn[i1, i2] == 0) conn[i1, i2] = conn[i2, i1] = 1
            r = rad(x$dist[j], rmin, rmax, radmax = 0.5*mag)
            ic = (rmax - x$dist[j]) / (rmax - rmin)
            if(is.list(cols)) {
              col = list(cols[[x$grp[j]]](ic)[1:3])
            }
            else {
              col = list(cols(ic)[1:3])
            }
            if(r > rr[i1, i2]) {
               rr[i1, i2] = rr[i2, i1] = r
               col.mat[i1, i2] = col.mat[i2, i1] = col
            }
         }
      }
      rownames(conn) <- res
      colnames(conn) <- res
      rownames(rr) <- res
      colnames(rr) <- res
   
      k = 0
      for(i in 1:(nrow(conn)-1)) {
         for(j in (i+1):ncol(conn)) {
            if(conn[i, j] == 1) {
               if(!is.numeric(colors)) {
#                 col = as.numeric(col2rgb(col.mat[i, j]))/255
                  col = unlist(col.mat[i, j]) / 255
                  cat("color change rgb [expr ", k, " + $color_start] ", paste(col, collapse=" "), "\n", sep="", file=file, append=TRUE)
                  cat("graphics top color [expr ", k, " + $color_start]\n", sep="", file=file, append=TRUE)
               }
               else {
                  cat("graphics top color ", colors, "\n", sep="", file=file, append=TRUE)
               }
               cat("draw cylinder {", pdb$xyz[atom2xyz(ca.inds$atom[res[i]])], 
                  "} {", pdb$xyz[atom2xyz(ca.inds$atom[res[j]])], "} radius", rr[i, j], 
                  " resolution 6 filled 0\n", sep=" ", file=file, append=TRUE)
               k = k + 1
            }
         }
      } 
   }
   else {
      k = 0
      for(j in 1:length(x$path)) {
         # get spline coordinates
         # interpolate at 10 points evenly distributed between two nodes
         xyz = matrix(pdb$xyz[atom2xyz(ca.inds$atom[x$path[[j]]])], nrow=3)
         spline.x = spline(xyz[1, ], n = ncol(xyz)+(ncol(xyz)-1)*10)$y
         spline.y = spline(xyz[2, ], n = ncol(xyz)+(ncol(xyz)-1)*10)$y
         spline.z = spline(xyz[3, ], n = ncol(xyz)+(ncol(xyz)-1)*10)$y
    
         # spline radius
         r = rad(x$dist[j], rmin, rmax, radmax=0.5*mag)

         # spline color
         ic = (rmax - x$dist[j]) / (rmax - rmin)

         if(is.list(cols)) {
            col = cols[[x$grp[j]]](ic)[1:3] / 255
         }
         else {
            col = cols(ic)[1:3] / 255
         }

         if(!is.numeric(colors)) {
            cat("color change rgb [expr ", k, " + $color_start] ", 
                paste(col, collapse=" "), "\n", sep="", file=file, append=TRUE)
            cat("graphics top color [expr ", k, " + $color_start]\n", sep="", file=file, append=TRUE)
         } else {
            cat("graphics top color ", colors, "\n", sep="", file=file, append=TRUE)
         } 
         for(i in 1:(length(spline.x) - 1)) { 
             cat("draw cylinder {", spline.x[i], spline.y[i], spline.z[i],
                  "} {", spline.x[i+1], spline.y[i+1], spline.z[i+1], "} radius", r,
                  " resolution 6 filled 0\n", sep=" ", file=file, append=TRUE)
         }
         k = k + 1
      }
   }

   # turn on display update
   cat("display update on\n", file=file, append=TRUE)

   write.pdb(pdb, file=pdbfile)
   
   if(launch) {

     ## Find default path to external program
     if(is.null(exefile)) {
       exefile <- 'vmd'
       if(nchar(Sys.which(exefile)) == 0) {
         os1 <- Sys.info()["sysname"]
         exefile <- switch(os1,
           Windows = 'vmd.exe', # to be updated
           Darwin = '/Applications/VMD\\ 1.9.*app/Contents/MacOS/startup.command',
           'vmd' )
       }
     }
     if(nchar(Sys.which(exefile)) == 0)
       stop(paste("Launching external program failed\n",
                  "  make sure '", exefile, "' is in your search path", sep=""))

     cmd <- paste(exefile, "-e", file)

     os1 <- .Platform$OS.type
     if (os1 == "windows") {
       shell(shQuote(cmd))
     } else{
       system(cmd)
     }
      
   }
}

vmd.ecnapath <- function(x, ...) {
   if(!inherits(x, "ecnapath")) {
      stop("The input 'x' must be an object of class 'ecnapath'.")
   }
   vmd.cnapath(x, ...)
}
