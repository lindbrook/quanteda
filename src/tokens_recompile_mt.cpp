//#include "dev.h"
#include "quanteda.h"
#include "recompile.h"
using namespace quanteda;

/* 
* This function recompiles tokens object.
* @used tokens_lookup()
* @creator Kohei Watanabe
* @param texts_ tokens ojbect
* @param types_ types in tokens
*/

// [[Rcpp::export]]
List qatd_cpp_tokens_recompile(const List &texts_, 
                               const CharacterVector types_){
    
    Texts texts = Rcpp::as<Texts>(texts_);
    Types types = Rcpp::as<Types>(types_);
    return recompile(texts, types);
    
}

/***R

#toks3 <- list(rep(0:5, 1), rep(10:15, 1))
toks3 <- list(0:26)
qatd_cpp_tokens_recompile(toks4, letters)

toks4 <- list(c(1:5))
qatd_cpp_tokens_recompile(toks4, c('あ', 'い', 'う', 'え', 'お'))



*/
