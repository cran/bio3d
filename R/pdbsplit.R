`pdbsplit` <-
function(pdb.files, ids=NULL, path="split_chain", overwrite=TRUE, verbose=FALSE, mk4=FALSE, ncore=1, progress=NULL, ...) {
  
  toread <- file.exists(pdb.files)
  toread[substr(pdb.files, 1, 4) == "http"] <- TRUE
  if (all(!toread)) 
    stop("No corresponding PDB files found")
  if (any(!toread)) {
    warning(paste("Missing files:\n\t",
                  paste(pdb.files[!toread], 
                        collapse = "\n\t"), sep = ""))
    pdb.files <- pdb.files[toread]
  }

  ## Parallelized by parallel package
  ncore <- setup.ncore(ncore, bigmem = FALSE)

  if(ncore>1) {
    mylapply <- mclapply
    prev.warn <- getOption("warn")
    options(warn=1)
  }
  else
    mylapply <- lapply

  ## Faster method to fetch chain IDs in a PDB file
  "quickscan" <- function(pdbfile) {
    fi <- readLines(pdbfile)
    fi = fi[ grep("^ATOM", fi) ]
    chains <- unique(substr(fi, 22,22))
    chains[chains == " "] <- NA
    return(chains)
  }

  if(!verbose)
    ## Initialize progress bar
    pb <- .init.pb(ncore, min=0, max=length(pdb.files))

  if(!file.exists(path)) 
     dir.create(path)
  
  "splitOnePdb" <- function(i, pdb.files, ids, path, overwrite, verbose, ...) {

    ## edit for shiny version
    if(!is.null(progress)) {
      progress$inc(1/length(pdb.files))
    }
    ## edit end

    out <- c(); skipped <- c(); unused <- NULL;
    if(!overwrite && !verbose) {
      chains <- quickscan(pdb.files[i])
    }
    else if(overwrite && !verbose) {
      invisible(capture.output( pdb <- read.pdb(pdb.files[i], verbose=verbose, ...) ))
      chains <- unique(pdb$atom[, "chain"])
    }
    else {
      pdb <- read.pdb(pdb.files[i], verbose=verbose, ...)
      chains <- unique(pdb$atom[, "chain"])
    }
    
    if(!is.null(ids)) {
      ids <- unique(ids)
      
      ## Match 'ids' with 'pdbId_chainId' combinations
      tmp.names <- paste0(basename.pdb(pdb.files[i], mk4=mk4), "_", chains)

      tmp.inds <- unique(unlist(lapply(ids, grep, tmp.names)))
      if(length(tmp.inds)==0) {
        ## Skip pdb file if no match were found
        unused <- basename.pdb(pdb.files[i], mk4=mk4)

        chains <- c()
      }
      else {
        chains <- chains[tmp.inds]
      }
    }

    if(!overwrite && !verbose) {
      tmp.names <- paste0(basename.pdb(pdb.files[i], mk4=mk4),"_", chains, ".pdb") 

      new.name <- file.path(path, tmp.names)
      if(all(file.exists(new.name))) {
        out <- c(out, new.name)
        skipped <- paste(basename(pdb.files[i]), " (",
                       paste(chains, collapse=","), ")", sep="")
        return( list(out=out, unused=unused, skipped=skipped) )
      }
      else {
        if(!verbose)
          invisible(capture.output( pdb <- read.pdb(pdb.files[i], verbose=verbose, ...) ))
        else
          pdb <- read.pdb(pdb.files[i], verbose=verbose, ...)
      }
    }
    
    if (length(chains) > 0) {
      for (j in 1:length(chains)) {
        if(!verbose)
          .update.pb(pb, step=1/length(chains))
        
        ##if (!is.na(chains[j])) {
          new.pdb <- NULL
          
          sel <- atom.select(pdb, chain=chains[j], verbose=verbose) #====
          new.pdb <- trim.pdb(pdb, sel, sse=TRUE)

          ## Multi-model records
          if (nrow(pdb$xyz)>1) {
            for ( k in 1:nrow(pdb$xyz) ) {
              
              str.len <- nchar(nrow(pdb$xyz))
              new.name <- paste(basename.pdb(pdb.files[i], mk4=mk4), 
                                "_", chains[j], ".", 
                                formatC(k, width=str.len, format="d", flag="0"),
                                ".pdb", sep = "")
              new.name <- file.path(path, new.name)
              
              xyz <- pdb$xyz[k, sel$xyz]

              if(length(new.pdb$xyz) > 0) {
                write.pdb(new.pdb, file = new.name, xyz=xyz, sse=TRUE)
                out <- c(out, new.name)
              }
              else {
                warning(paste0(basename(new.name), " has 'xyz' of length zero"))
              }
            }
          }
          else {
            new.name <- paste0(basename.pdb(pdb.files[i], mk4=mk4), "_", chains[j], ".pdb") 
            new.name <- file.path(path, new.name)

            if(length(new.pdb$xyz) > 0) {
              if(!file.exists(new.name) | overwrite )
                write.pdb(new.pdb, file = new.name, sse=TRUE)
              
              out <- c(out, new.name)
            }
            else {
              warning(paste0(basename(new.name), " has 'xyz' of length zero"))
            }
          }
        ##}
      }
    }
    else {
      if(!verbose) .update.pb(pb, step=1)
    }

    gc()
    return( list(out=out, unused=unused, skipped=skipped) )
  }
  
  outdata <- mylapply(1:length(pdb.files), splitOnePdb,
                      pdb.files, ids, path, overwrite, verbose, ...)

  if(ncore>1)
    options(warn=prev.warn)
  
  ##### Collect data #####
  outfiles <- c()
  unused <- c(); skipped <- c();
  for(i in 1:length(outdata)) {
    tmp.out <- outdata[[i]]
    outfiles <- c(outfiles, tmp.out$out)
    unused <- c(unused, tmp.out$unused)
    skipped <- c(skipped, tmp.out$skipped)
  }

  if(!verbose) {
    .update.pb(pb)
    .close.pb(pb)
  }
 
  if(!is.null(ids)) {
    ids.used <- NULL; nonmatch <- NULL
    if(length(outfiles)>0) {
      ids.used <- sub(".pdb$", "", basename(outfiles))
      tmp.fun <- function(x, y) { ifelse(length(grep(x,y))>0, TRUE, FALSE) }
      tmp.inds <- unlist(lapply(ids, tmp.fun, ids.used))
      nonmatch <- ids[!tmp.inds]
    }

    ## Elements of 'pdb.files' not in use
    if(length(unused)>0) {
      unused <- paste(unused, collapse=", ")
      warning(paste("unmatched pdb files:", unused))
    }

    ## Elements of 'ids' not in use
    if(length(nonmatch)>0) {
      nonmatch <- paste(nonmatch, collapse=", ")
      warning(paste("unmatched ids:", nonmatch))
    }
  }

  if(length(skipped)>0) {
    warning(paste(skipped, collapse=", "))
  }

  return(outfiles)
}
