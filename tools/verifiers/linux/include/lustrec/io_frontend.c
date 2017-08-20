#include <stdlib.h> /* Provides exit */
#include <stdio.h> /* Provides printf, scanf, sscanf */
#include <unistd.h> /* Provides isatty */
#include "io_frontend.h"

int ISATTY;

/* Standard Input procedures **************/
_Bool _get_bool(FILE* file, char* n){
   char b[512];
   _Bool r = 0;
   int s = 1;
   char c;
   do {
      if(ISATTY) {
         if((s != 1)||(r == -1)) printf("\a");
         printf("%s (1,t,T/0,f,F) ? ", n);
      }
      if(scanf("%s", b)==EOF) exit(0);
      s = sscanf(b, "%c", &c);
      r = -1;
      if((c == '0') || (c == 'f') || (c == 'F')) r = 0;
      if((c == '1') || (c == 't') || (c == 'T')) r = 1;
   } while((s != 1) || (r == -1));
   fprintf(file, "%i\n",r);
   return r;
}

int _get_int(FILE* file, char* n){
   char b[512];
   int r;
   int s = 1;
   do {
      if(ISATTY) {
         if(s != 1) printf("\a");
         printf("%s (integer) ? ", n);
      }
      if(scanf("%s", b)==EOF) exit(0);
      s = sscanf(b, "%d", &r);
   } while(s != 1);
   fprintf(file, "%d\n", r);
   return r;
}

double _get_double(FILE* file, char* n){
   char b[512];
   double r;
   int s = 1;
   do {
      if(ISATTY) {
         if(s != 1) printf("\a");
         printf("%s (double) ? ", n);
      }
      if(scanf("%s", b)==EOF) exit(0);
      s = sscanf(b, "%lf", &r);
   } while(s != 1);
   fprintf(file, "%f\n", r);
   return r;
}
/* Standard Output procedures **************/
void _put_bool(FILE* file, char* n, _Bool _V){
  if(ISATTY) {
    printf("%s = ", n);
  } else {
    printf("'%s': ", n);
  };
  printf("'%i' ", (_V)? 1 : 0);
  printf("\n");
  fprintf(file, "%i\n", _V);
}
void _put_int(FILE* file, char* n, int _V){
  if(ISATTY) {
    printf("%s = ", n);
  } else {
    printf("'%s': ", n);
  };
  printf("'%d' ", _V);
  printf("\n");
  fprintf(file, "%d\n", _V);
}
void _put_double(FILE* file, char* n, double _V){
  if(ISATTY) {
    printf("%s = ", n);
  } else {
    printf("'%s': ", n);
  };
  printf("'%f' ", _V);
  printf("\n");
  fprintf(file, "%f\n", _V);
}
