// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// read_cif
List read_cif(std::string filename, int maxlines, bool multi);
RcppExport SEXP bio3d_read_cif(SEXP filenameSEXP, SEXP maxlinesSEXP, SEXP multiSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type filename(filenameSEXP);
    Rcpp::traits::input_parameter< int >::type maxlines(maxlinesSEXP);
    Rcpp::traits::input_parameter< bool >::type multi(multiSEXP);
    rcpp_result_gen = Rcpp::wrap(read_cif(filename, maxlines, multi));
    return rcpp_result_gen;
END_RCPP
}
// read_crd
List read_crd(std::string filename);
RcppExport SEXP bio3d_read_crd(SEXP filenameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type filename(filenameSEXP);
    rcpp_result_gen = Rcpp::wrap(read_crd(filename));
    return rcpp_result_gen;
END_RCPP
}
// read_pdb
List read_pdb(std::string filename, bool multi, bool hex, int maxlines, bool atoms_only);
RcppExport SEXP bio3d_read_pdb(SEXP filenameSEXP, SEXP multiSEXP, SEXP hexSEXP, SEXP maxlinesSEXP, SEXP atoms_onlySEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type filename(filenameSEXP);
    Rcpp::traits::input_parameter< bool >::type multi(multiSEXP);
    Rcpp::traits::input_parameter< bool >::type hex(hexSEXP);
    Rcpp::traits::input_parameter< int >::type maxlines(maxlinesSEXP);
    Rcpp::traits::input_parameter< bool >::type atoms_only(atoms_onlySEXP);
    rcpp_result_gen = Rcpp::wrap(read_pdb(filename, multi, hex, maxlines, atoms_only));
    return rcpp_result_gen;
END_RCPP
}
// read_prmtop
List read_prmtop(std::string filename);
RcppExport SEXP bio3d_read_prmtop(SEXP filenameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type filename(filenameSEXP);
    rcpp_result_gen = Rcpp::wrap(read_prmtop(filename));
    return rcpp_result_gen;
END_RCPP
}