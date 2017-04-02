#include "pairix.h"

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


//load + get size of the query result
void get_size(char** pfn, char** pquerystr, int* pn, int* pmax_len, int* pflag){

   int len=-1;
   const char *s;

   pairix_t *tb = load(*pfn);

   if(tb){
     const ti_conf_t *idxconf = ti_get_conf(tb->idx);
     ti_iter_t iter = ti_querys_2d(tb, *pquerystr);
  
     *pn=0;
     *pmax_len=0;
     while ((s = ti_read(tb, iter, &len)) != 0) {
       // if ((int)(*s) != idxconf->meta_char) break;    // I don't fully understand this line. Works without the line.
       if(len>*pmax_len) *pmax_len = len;
       (*pn)++;
     }
 
     ti_close(tb);
   }
   else *pflag = -1; // error
}


//load + return the result
void get_lines(char** pfn, char** pquerystr, char** presultstr, int* pflag){

   int len=-1;
   const char *s;
   int k=0;

   pairix_t *tb = load(*pfn);
   if(tb){
     const ti_conf_t *idxconf = ti_get_conf(tb->idx);
     ti_iter_t iter = ti_querys_2d(tb, *pquerystr);

     while ((s = ti_read(tb, iter, &len)) != 0) {
       // if ((int)(*s) != idxconf->meta_char) break;    // I don't fully understand this line. Works without the line.
       strcpy(presultstr[k++],s);
     }

     ti_close(tb);
   }
   else *pflag= -1;  // error
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




