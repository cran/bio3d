`blast.pdb` <-
function(seq, database="pdb", time.out=NULL, chain.single=TRUE) {
  if(inherits(seq, "fasta")) {
    if(is.matrix(seq$ali)) {
      if(nrow(seq$ali)>1)
        warning("Multiple sequences detected - using only the first sequence in input object")
      seq <- as.vector(seq$ali[1,])
    }
    else {
      seq <- as.vector(seq$ali)
    }
  }

  ## Extract sequence 'seq' from possible pdb input
  if(is.pdb(seq)) {
    seq <- pdbseq(seq)
  }

  ## Run NCBI blastp on a given 'seq' sequence against a given 'database'
  if(!is.vector(seq)) {
    stop("Input 'seq' should be a single sequence as a single or multi element character vector (as obtained from the pdbseq() function)")
  }
  seq <- paste(seq, collapse="")
  
  if( !(database %in% c("pdb", "nr", "swissprot")) )
    stop("Option database should be one of pdb, nr or swissprot")

  ##- Submit
  if(nchar(seq)>30) {
     urlput <- paste("https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Put&DATABASE=",
                     database,"&HITLIST_SIZE=20000&PROGRAM=blastp&CLIENT=web&QUERY=",
                     paste(seq,collapse=""),
                     sep="")
  }
  else {
    # mimic the 'Automatically adjust parameters for short input sequences' option on NCBI
    urlput <- paste("https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Put&DATABASE=",
                    database,"&HITLIST_SIZE=500&PROGRAM=blastp&CLIENT=web&",
                    "MATRIX=PAM30&MATRIX_NAME=PAM30&EXPECT=200000&",
                    "WORD_SIZE=2&GAPCOSTS=9 1&", "THRESHOLD=11&", 
                    "COMPOSITION_BASED_STATISTICS=0&QUERY=",
                    paste(seq,collapse=""),
                    sep="")    
  }
  
  txt <- scan(urlput, what="raw", sep="\n", quiet=TRUE)
  rid <- sub("^.*RID = " ,"",txt[ grep("RID =",txt) ])

  urlget <- paste("https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Get",
                  "&FORMAT_OBJECT=Alignment",
                  "&ALIGNMENT_VIEW=Tabular",
                  "&RESULTS_FILE=on",
                  "&FORMAT_TYPE=CSV",
                  "&ALIGNMENTS=20000",
                  "&DESCRIPTIONS=20000",
                  "&RID=",rid, sep="")

  blast <- get.blast(urlget, time.out = time.out, chain.single=chain.single)
  return(blast)
}
