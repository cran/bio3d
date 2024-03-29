get.blast <- function(urlget, time.out = NULL, chain.single=TRUE) {

  if(substr(urlget, 1, 5) == "https" && grep("Blast.cgi", urlget)
      && grep("RID[[:space:]]*=", urlget)) {
     rid <- sub("^.*RID[[:space:]]*=[[:space:]]*", "", urlget)
     names(urlget)=rid 
  } else {
     stop("Illegal link for retrieving BLAST results")
  }

  cat(paste(" Searching ... please wait (updates every 5 seconds) RID =",rid,"\n "))

  ##- Retrieve results via RID code and check for job completion
  ##   (completion is based on retrieving HTML or CSV output)
  html <- 1
  t.count <- 0
  repeat {
    raw  <- try(read.csv(urlget,
                     header = FALSE, sep = ",", quote="", dec=".",
                     fill = TRUE, comment.char="", stringsAsFactors=FALSE), silent=TRUE)
    if(inherits(raw, "try-error")) { stop("No hits found: thus no output generated") }
    html <- grep("DOCTYPE", raw[1,])
    
    if(!is.null(time.out) && (t.count > time.out) || (length(html) != 1))
      break;
    
    cat("."); Sys.sleep(5)
    t.count <- t.count + 5
  }
  
  if(length(html) == 1) {
     warning("\nTime out (", time.out, "s): Retrieve results with returned link\n", 
        urlget, "\n", sep="")
     return(urlget)
  }
  
  colnames(raw) <- c("queryid", "subjectids", "identity", 
                     "alignmentlength", "mismatches", "gapopens",
                     "q.start", "q.end", "s.start", "s.end",
                     "evalue", "bitscore", "positives")
  
  ##- Expand 'raw' for each hit in 'subjectids' (i.e. split on ";")
  eachsubject <- strsplit(raw$subjectids, ";")
  subjectids  <- unlist(eachsubject)
  n.subjects  <- sapply(eachsubject, length)

  df <- raw[rep(row.names(raw), times=n.subjects), ]
  df$subjectids <- subjectids
  row.names(df) <- 1:nrow(df)
    
  ##- Parse ids
  #all.ids <- strsplit(subjectids, "\\|")
  #gi.id  <- sapply(all.ids, '[', 2)
  gi.id <- subjectids
  
  all.ids <- strsplit(subjectids, "_")
  pdb.4char <- sapply(all.ids, '[', 1)
  pdb.chain <- sapply(all.ids, '[', 2)

  ## Catch long chain IDs as in hits from "P12612" (e.g "1WF4_GG" => "1WF4_g")
  if(chain.single) {
    chain.ind <- which(nchar(pdb.chain) > 1 & nchar(pdb.4char)==4)
    if(length(chain.ind) > 0) {
      pdb.chain[ chain.ind ] <- tolower( substr(pdb.chain[ chain.ind ],1,1 ) )
    }
  }
  pdb.id <- rep(NA, length(pdb.4char))
  tinds <- !is.na(pdb.chain) & nchar(pdb.4char)==4
  pdb.id[tinds] <- paste(pdb.4char[tinds],"_",pdb.chain[tinds],sep="")


  ##- Map zero evalues to arbitrarily high value for -log(evalue)
  df$mlog.evalue <- -log(df$evalue)
  df$mlog.evalue[is.infinite(df$mlog.evalue)] <- -log(1e-308)
  df$pdb.id <- pdb.id
  df$acc <- gi.id
  
  cat(paste("\n Reporting",length(pdb.id),"hits\n"))

  # sort hit table according to mlog.evalue
  df <- df[order(df$mlog.evalue, decreasing = TRUE), ]  
  output <- list(hit.tbl = df,
                 raw = raw,
                 url = urlget)
  
  class(output) <- "blast"
  return(output)
}
