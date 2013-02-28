//FILE OPTIQTM.C

#define _LINUX_
//Comment this line out if you compile with MinGW under Windows.
//This disables the SIGNAL handling.

#define NUM_GROUPS 2

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <assert.h>
#include  <signal.h>
#include "cubedefs.h"
#include<time.h>
#include<stdint.h>
#include<sys/time.h>

struct timeval start;
struct timeval end;
uint64_t msecs;

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

#pragma omp parallel num_threads(NUM_GROUPS) private(cc_a,manString)

{
int ID = omp_get_thread_num();
printf("Hello from thread %d %d\n",ID,omp_get_thread_num());
int ext = 0;
int cont = 0;
#pragma omp barrier
FILE *groupOut = NULL;
char groupOutFileName[50];
sprintf(groupOutFileName,"OpenMPHybridDepth1Group%dout.txt",ID);
groupOut = fopen(groupOutFileName,"w");
close(groupOut);

omp_set_nested(1);

while (1)
{
	#pragma omp critical
	{
		printf("enter cube (x to exit): ");fflush(stdout);
		if (fgets(manString,sizeof(manString),stdin)==NULL) ext=1;
		if(ext==0){
			if (manString[0]=='x') ext=1;
			gettimeofday(&start,NULL);
			l=strlen(manString);
			if (manString[l-1]=='\n') manString[l-1]=0;//remove LF
			if (l>1 && manString[l-2]=='\r') manString[l-2]=0;//remove CR if present
			if (strlen(manString)==0) cont=1;
			if(cont == 0){
				printf("\nsolving optimal: %s\n",manString);fflush(stdout);
			}
		}
	}
	if(ext){break;}
	if(cont){continue;}
	cc_a = stringToCubieCube(manString);
	#ifdef _LINUX_ 
  	if (sigsetjmp(jump_buf, 1) == 0)
	{
		signal(SIGINT, user_break);
		solveOptimal(cc_a,ID);
		printf("Solved\n");
		gettimeofday(&end,NULL);		
		msecs = (end.tv_sec * 1000000 + end.tv_usec) - (start.tv_sec * 1000000 - start.tv_usec);
		printf("\nTime elapsed for %s: %f\nEND-OF-SOLVE\n",manString,1.0*msecs/1000000.0);fflush(stdout);
	}
	signal(SIGINT, SIG_IGN);
	#else
	solveOptimal(cc_a,ID);
	printf("Solved\n");
	gettimeofday(&end,NULL);		
	msecs = (end.tv_sec * 1000000 + end.tv_usec) - (start.tv_sec * 1000000 - start.tv_usec);
	printf("\nTime elapsed for %s: %f\nEND-OF-SOLVE\n",manString,1.0*msecs/1000000.0);fflush(stdout);
	#endif
	printf("Concatenating into one file\n");
	int threadCounter = 0;
	FILE *groupOut = NULL;

	char groupOutFileName[50];
	sprintf(groupOutFileName,"OpenMPHybridDepth1Group%dout.txt",ID);
	groupOut = fopen(groupOutFileName,"a");
	FILE *tempIn = NULL;
	char inFileName[50];
	char line[100];

	printf("Entering loop\n");
	
	for(threadCounter=0;threadCounter<NUM_THREADS;threadCounter++){
		sprintf(inFileName,"OpenMPHybridDepth1Thread%dGroup%dOut.txt",threadCounter,ID);
		printf("%s\n",inFileName);
		tempIn = fopen(inFileName,"r");
		while(fgets(line,sizeof line,tempIn) != NULL){
			fprintf(groupOut,line);
			fflush(groupOut);
		}
		fclose (tempIn);
		fprintf(groupOut,"\n\n\n");
		fflush(groupOut);
	}
	
	
	fprintf(groupOut,"\nTime elapsed for %s: %f\nEND-OF-SOLVE\n",manString,(1.0*msecs/1000000.0));fflush(groupOut);

	fclose(groupOut);

	
}
}

printf("Writing to all out\n");
FILE *allOut = NULL;

allOut = fopen("OpenMPHybridDepth1AllOut.txt","w");
FILE *tempIn = NULL;
char inFileName[50];
char line[100];
int threadCounter;

printf("Entering all out loop\n");
for(threadCounter=0;threadCounter<getNumThreads();threadCounter++){
	sprintf(inFileName,"OpenMPHybridDepth1Group%dout.txt",threadCounter);
	tempIn = fopen(inFileName,"r");
	while(fgets(line,sizeof line,tempIn) != NULL){
		fprintf(allOut,line);
		fflush(allOut);
	}
	fclose (tempIn);
	fprintf(allOut,"\n\n\n");
	fflush(allOut);
}

fclose(allOut);


return 0;
}
