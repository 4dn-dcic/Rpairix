#include "pairix.h"
#include <sys/stat.h>
#include <R.h>
#include <Rdefines.h>

// load
pairix_t *load(char* fn){

  pairix_t *tb=NULL; 

  // index file name
  char fnidx[strlen(fn)+5];
  strcpy(fnidx,fn);
  strcpy(fnidx+strlen(fn),".px2");

  // open file
  if( tb = ti_open(fn, fnidx) )   
    tb->idx = ti_index_load(fn);
  return(tb);
}


//get number of seq(chr)pairs
void get_keylist_size(char** pfn, int *pn, int* pmax_key_len, int* pflag){
  int len;
  int i;
  pairix_t *tb = load(*pfn);
  if(tb){
    char** ss = ti_seqname(tb->idx, pn);
    *pmax_key_len=0;
    for(i=0;i<*pn;i++){
      len=strlen(ss[i]);
      if(len>*pmax_key_len) *pmax_key_len=len;
    }
    free(ss);
    ti_close(tb);
  }
  else *pflag= -1; // error
}

//get the list of seq(chr)pair
void get_keylist(char** pfn, char** pkeylist, int* pflag){
  int n,i;
  pairix_t *tb = load(*pfn);
  if(tb){
    char **ss = ti_seqname(tb->idx, &n);
    for(i=0;i<n;i++){
      strcpy(pkeylist[i],ss[i]);
    }
    free(ss);
    ti_close(tb);
  }
  else *pflag = -1; // error
}

//check if a key (chr for 1D, chr pair for 2D) exists
void key_exists(char** pfn, char** pkey, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_tid(tb->idx, *pkey)!=-1?1:0;
  }
  else *pflag= -1;
}


//get column indices (1-based)
void get_chr1_col(char** pfn, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_sc(tb->idx)+1;
  }
  else *pflag= -1;
}

void get_chr2_col(char** pfn, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_sc2(tb->idx)+1;
  }
  else *pflag= -1;
}

void get_startpos1_col(char** pfn, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_bc(tb->idx)+1;
  }
  else *pflag= -1;
}

void get_startpos2_col(char** pfn, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_bc2(tb->idx)+1;
  }
  else *pflag= -1;
}

void get_endpos1_col(char** pfn, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_ec(tb->idx)+1;
  }
  else *pflag= -1;
}

void get_endpos2_col(char** pfn, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_ec2(tb->idx)+1;
  }
  else *pflag= -1;
}


// checks if the file is 1D-indexed or 2D-indexed.
// returns 2 or 1, or -1 if file can't be opened.
void check_1d_vs_2d(char** pfn, int* pflag){
  pairix_t *tb = load(*pfn);
  if(tb){
    *pflag = ti_get_sc2(tb->idx)+1==0?1:2;
  }
  else *pflag= -1;
}


SEXP setInt() {
   SEXP myint;
   int *p_myint;
   int len = 5;

   // Allocating storage space:
   PROTECT(myint = NEW_INTEGER(len));  
   p_myint = INTEGER_POINTER(myint);
   p_myint[0] = 7;
   UNPROTECT(1);
   return myint;
}

SEXP getChar(SEXP mychar) {
  char *Pmychar[5];  // array of 5 pointers 
                       // to character strings

  PROTECT(mychar = AS_CHARACTER(mychar)); 

  // allocate memory:
  Pmychar[0] = R_alloc(strlen(CHAR(STRING_ELT(mychar, 0))), sizeof(char)); 
  Pmychar[1] = R_alloc(strlen(CHAR(STRING_ELT(mychar, 1))), sizeof(char)); 

  // ... and copy mychar to Pmychar: 
  strcpy(Pmychar[0], CHAR(STRING_ELT(mychar, 0))); 
  strcpy(Pmychar[1], CHAR(STRING_ELT(mychar, 1))); 

  printf(" Printed from C:");
  printf(" %s %s \n",Pmychar[0],Pmychar[1]);
  UNPROTECT(1);
  return(R_NilValue); 
}


SEXP getChar2(SEXP mychar, SEXP mypn) {
  PROTECT(mypn = AS_INTEGER(mypn));
  int *pn = INTEGER_POINTER(mypn);
  printf(" Printed from C: %d strings\n", *pn);
  char *Pmychar[*pn];  // array of n pointers 
                       // to character strings

  PROTECT(mychar = AS_CHARACTER(mychar)); 

  int i;
  for(i=0;i<*pn;i++){
    Pmychar[i] = R_alloc(strlen(CHAR(STRING_ELT(mychar, i))), sizeof(char)); 
    strcpy(Pmychar[i], CHAR(STRING_ELT(mychar, i))); 
    printf(" %s\n",Pmychar[i]);
  }

  (*pn)++;

  UNPROTECT(2);
  return(R_NilValue); 
}


//.Call-compatible
//load + get size of the query result
//input:
//  _r_pfn : input filename (a single character string)
//  _r_pquerystr : a character vector of query strings
//  _r_pnquery : length _r_pquerystr (number of elements in the vector)
//output is an R integer vector containing (n, max_len, flag).
//  n : number of output lines
//  max_len : maximum length of output lines
//  flag : 0 if successfully run, -1 if there is an error (e.g. can't open input file)
SEXP get_size(SEXP _r_pfn, SEXP _r_pquerystr, SEXP _r_pnquery){ 

   // input conversion from R to C
   // number of queries
   PROTECT(_r_pnquery = AS_INTEGER(_r_pnquery));
   int *pnquery = INTEGER_POINTER(_r_pnquery);

   // file name
   char *pfn[1];
   PROTECT(_r_pfn = AS_CHARACTER(_r_pfn));
   pfn[0] = R_alloc(strlen(CHAR(STRING_ELT(_r_pfn, 0))), sizeof(char));
   strcpy(pfn[0], CHAR(STRING_ELT(_r_pfn, 0))); 

   // queries
   char *pquerystr[*pnquery];
   PROTECT(_r_pquerystr = AS_CHARACTER(_r_pquerystr));
   int i;
   for(i=0;i<*pnquery;i++){
     pquerystr[i] = R_alloc(strlen(CHAR(STRING_ELT(_r_pquerystr, i))), sizeof(char)); 
     strcpy(pquerystr[i], CHAR(STRING_ELT(_r_pquerystr, i))); 
   }

   // to be return values
   int n=0, max_len=0, flag=0;

   int len=-1;
   const char *s;

   pairix_t *tb = load(*pfn);

   if(tb){
     const ti_conf_t *idxconf = ti_get_conf(tb->idx);

     int i;
     for(i=0;i<*pnquery;i++){
       ti_iter_t iter = ti_querys_2d(tb, pquerystr[i]);
       while ((s = ti_read(tb, iter, &len)) != 0) {
         // if ((int)(*s) != idxconf->meta_char) break;    // I don't fully understand this line. Works without the line.
         if(len>max_len) max_len = len;
         n++;
       }
     }

     ti_close(tb);
   }
   else flag = -1; // error
   
   // output 
   // preturn = (n, max_len, flag)
   SEXP _r_preturn;
   PROTECT(_r_preturn = NEW_INTEGER(3));
   int *preturn = INTEGER_POINTER(_r_preturn);
   preturn[0] = n;
   preturn[1] = max_len;
   preturn[2] = flag;

   UNPROTECT(4);
   return(_r_preturn);
}


//.Call-compatible
//load + return the result
//input:
//  _r_pfn : input filename (a single character string)
//  _r_pquerystr : a character vector of query strings
//  _r_pnquery : length _r_pquerystr (number of elements in the vector)
//  _r_pn : length of the result strings (number of lines)
//output is an R list containing (resultstr, flag).
//  resultstr : a character vector of result strings
//  flag : 0 if successfully run, -1 if there is an error (e.g. can't open input file)
SEXP get_lines(SEXP _r_pfn, SEXP _r_pquerystr, SEXP _r_pnquery, SEXP _r_pn){ 

   // input conversion from R to C
   // number of queries
   PROTECT(_r_pnquery = AS_INTEGER(_r_pnquery));
   int *pnquery = INTEGER_POINTER(_r_pnquery);

   // file name
   char *pfn[1];
   PROTECT(_r_pfn = AS_CHARACTER(_r_pfn));
   pfn[0] = R_alloc(strlen(CHAR(STRING_ELT(_r_pfn, 0))), sizeof(char));
   strcpy(pfn[0], CHAR(STRING_ELT(_r_pfn, 0))); 

   // queries
   char *pquerystr[*pnquery];
   PROTECT(_r_pquerystr = AS_CHARACTER(_r_pquerystr));
   int i;
   for(i=0;i<*pnquery;i++){
     pquerystr[i] = R_alloc(strlen(CHAR(STRING_ELT(_r_pquerystr, i))), sizeof(char)); 
     strcpy(pquerystr[i], CHAR(STRING_ELT(_r_pquerystr, i))); 
   }

   // number of lines in the query result
   PROTECT(_r_pn = AS_INTEGER(_r_pn));
   int *pn = INTEGER_POINTER(_r_pn);

   // to be return values
   //char **presultstr;
   SEXP _r_presultstr;
   PROTECT(_r_presultstr = allocVector(STRSXP, *pn));
   int flag=0;

   int len=-1;
   const char *s;
   int k=0;

   pairix_t *tb = load(*pfn);

   if(tb){
     const ti_conf_t *idxconf = ti_get_conf(tb->idx);

     int i;
     for(i=0;i<*pnquery;i++){
       ti_iter_t iter = ti_querys_2d(tb, pquerystr[i]);
       while ((s = ti_read(tb, iter, &len)) != 0) {
         // if ((int)(*s) != idxconf->meta_char) break;    // I don't fully understand this line. Works without the line.
         // strcpy(presultstr[k++],s);
         SET_STRING_ELT(_r_presultstr, k++, mkChar(s)); 
       }
     }

     ti_close(tb);
   }
   else flag = -1; // error
   
   // output 
   // preturn = (n, max_len, flag)
   SEXP _r_preturn;
   PROTECT(_r_preturn = allocVector(VECSXP, 2));
   SET_VECTOR_ELT(_r_preturn, 0, _r_presultstr);

   // preturn_flag : flag
   SEXP _r_preturn_flag;
   PROTECT(_r_preturn_flag = NEW_INTEGER(1));
   int *preturn_flag = INTEGER_POINTER(_r_preturn_flag);
   preturn_flag[0] = flag;

   SET_VECTOR_ELT(_r_preturn, 1, _r_preturn_flag);

   UNPROTECT(7);
   return(_r_preturn);
}



void build_index(char **pinputfilename, char **ppreset, int *psc, int *pbc, int *pec, int *psc2, int *pbc2, int *pec2, char **pdelimiter, char **pmeta_char, int *pline_skip, int *pforce, int *pflag){

  if(*pforce==0){
    char *fnidx = calloc(strlen(*pinputfilename) + 5, 1);
    strcat(strcpy(fnidx, *pinputfilename), ".px2");
    struct stat stat_px2, stat_input;
     if (stat(fnidx, &stat_px2) == 0){  // file exists.
         // Before complaining, check if the input file isn't newer. This is a common source of errors,
         // people tend not to notice that pairix failed
         stat(*pinputfilename, &stat_input);
         if ( stat_input.st_mtime <= stat_px2.st_mtime ) *pflag=-4;
     }
     free(fnidx);
  }
  if(*pflag != -4){
    if ( bgzf_is_bgzf(*pinputfilename)!=1 ) *pflag = -3;
    else {
      ti_conf_t conf;
      if (strcmp(*ppreset, "") == 0 && *psc != 0 && *pbc != 0){
        conf.sc = *psc;
        conf.bc = *pbc;
        conf.ec = *pec;
        conf.sc2 = *psc2;
        conf.bc2 = *pbc2;
        conf.ec2 = *pec2;
        conf.delimiter = (*pdelimiter)[0];
        conf.meta_char = (int)((*pmeta_char)[0]);
        conf.line_skip = *pline_skip;
      }
      else if (strcmp(*ppreset, "gff") == 0) conf = ti_conf_gff;
      else if (strcmp(*ppreset, "bed") == 0) conf = ti_conf_bed;
      else if (strcmp(*ppreset, "sam") == 0) conf = ti_conf_sam;
      else if (strcmp(*ppreset, "vcf") == 0 || strcmp(*ppreset, "vcf4") == 0) conf = ti_conf_vcf;
      else if (strcmp(*ppreset, "psltbl") == 0) conf = ti_conf_psltbl;
      else if (strcmp(*ppreset, "pairs") == 0) conf = ti_conf_pairs;
      else if (strcmp(*ppreset, "merged_nodups") == 0) conf = ti_conf_merged_nodups;
      else if (strcmp(*ppreset, "old_merged_nodups") == 0) conf = ti_conf_old_merged_nodups;
      else *pflag = -2;  // wrong preset

      if (*pflag != -2 ) *pflag= ti_index_build(*pinputfilename, &conf);  // -1 if failed
    }
  }
}



