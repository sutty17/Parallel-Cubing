//FILE OPTIQTM.C

#define _LINUX_
//Comment this line out if you compile with MinGW under Windows.
//This disables the SIGNAL handling.

#define NUM_THREADS 2

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <assert.h>
#include  <signal.h>
#include <time.h>
#include "cubedefs.h"
#include <omp.h>

static char manString[256];
int subOptLev;
int symRed;

#ifdef _LINUX_
static sigjmp_buf jump_buf;
#endif

CubieCube cc_a;


#ifdef _LINUX_ 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void  user_break(int  n)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
{
printf("-- skipping cube --\n");
fflush(stdout);
siglongjmp(jump_buf, 1);
return;
}
#endif

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void  pp()
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
{
printf(".");
fflush(stdout);
return;
}


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int main(int argc, char * argv[])
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
{
int i,l;
subOptLev=-1;
symRed=1;
for (i=1;i<argc;i++)
{
	if (argv[i][0]=='+')//all optimal solutions/suboptimal solutions
	{
		subOptLev=0;
		if  (argv[i][1]>'0' && argv[i][1]<='9') subOptLev= argv[i][1]-48;
	}
	if (argv[i][0]=='-')
	{
		if (argv[i][1]=='s') symRed=0;
	}
}

printf("initializing memory.\n");
visitedA = (char *)calloc(NGOAL/8+1,1);//initialized to 0 by default
visitedB = (char *)calloc(NGOAL/8+1,1);
for (l=0;l<NTWIST;l++)
movesCloserToTarget[l] = (short *)calloc(NFLIPSLICE*2,2);

printf("initializing tables");fflush(stdout);
initSymCubes();
initMoveCubes();
initInvSymIdx();
initSymIdxMultiply();
initMoveConjugate();
initMoveBitsConjugate();
initGESymmetries();
initTwistConjugate();pp();
initRawFLipSliceRep();pp();
initTwistMove();pp();
initCorn6PosMove();pp();
initEdge4PosMove();pp();
initEdge6PosMove();pp();
initSymFlipSliceClassMove();pp();
initMovesCloserToTarget();pp();
initNextMove();pp();
printf("\r\n");


        #pragma omp parallel num_threads(NUM_THREADS) private(cc_a)
{
int ext = 0;
int cont = 0;
int ID = omp_get_thread_num();
printf("Hello from thread %d\n",ID);
while (1)
{	
	#pragma omp critical
	{
	ext=0;
	cont=0;
	printf("In critical section, thread %d\n",ID);
	printf("enter cube (x to exit): ");fflush(stdout);
	if (fgets(manString,sizeof(manString),stdin)==NULL) ext=1;
	if(ext == 0){
	if (manString[0]=='x') exit(EXIT_SUCCESS);
	l=strlen(manString);
	if (manString[l-1]=='\n') manString[l-1]=0;//remove LF
	if (l>1 && manString[l-2]=='\r') manString[l-2]=0;//remove CR if present
	if (strlen(manString)==0) cont = 1;//ignore empty lines
	if(cont == 0){
	printf("\nsolving optimal: %s\n",manString);fflush(stdout);
	
	cc_a = stringToCubieCube(manString);
	}
	}
	}
	if(ext ==1) break;	
	if(cont == 1) continue;
	#ifdef _LINUX_ 
	clock_t start = clock();
  	if (sigsetjmp(jump_buf, 1) == 0)
	{
		signal(SIGINT, user_break);
		solveOptimal(cc_a);
		printf("\nTime elapsed for %s: %f\nEND-OF-SOLVE\n",manString,((double) clock() - start) / CLOCKS_PER_SEC);fflush(stdout);
	}
	signal(SIGINT, SIG_IGN);
	#else
	solveOptimal(cc_a);
	printf("\nTime elapsed for %s: %f\nEND-OF-SOLVE\n",manString,((double) clock() - start) / CLOCKS_PER_SEC);fflush(stdout);
	#endif
	}
}
exit(EXIT_SUCCESS);
return 0;
}
