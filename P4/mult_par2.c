//P4 arq 2020-2021
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <omp.h>

#include "arqo4.h"

int mainCleanUp(tipo**, tipo**, tipo**, int);

int main(int argc, char *argv[])
{
    int n;
    int i;
    int j;
    int k;
    tipo **A = NULL;
    tipo **B = NULL;
    tipo **C = NULL;
    struct timeval fin,ini;

    printf("Word size: %ld bits\n",8*sizeof(tipo));

    if(argc!=2)
    {
        printf("Error: %s <matrix size>\n", argv[0]);
        return -1;
    }
    n = atoi(argv[1]);
    A = generateMatrix(n);
    if(!A)
    {
        return -1;
    }
    B = generateMatrix(n);
    if(!B)
    {
        return mainCleanUp(A, NULL, NULL, -1);
    }
    C = generateEmptyMatrix(n);
    if(!C)
    {
        return mainCleanUp(A, B, NULL, -1);
    }

    gettimeofday(&ini,NULL);

    /* Main computation */
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++) {
            for (k = 0; k < n; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    /* End of computation */

    gettimeofday(&fin,NULL);
    printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
#ifdef DEBUG
    printf("Result:\n");
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++) {
            printf("%lf\t", C[i][j]);
        }
        printf("\n");
    }
#endif

    return mainCleanUp(A, B, C, 0);
}

int mainCleanUp(tipo** A, tipo** B, tipo** C, int retVal) {
    if (A) free(A);
    if (B) free(B);
    if (C) free(C);
    return retVal;
}
