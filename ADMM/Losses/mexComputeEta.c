#include "mex.h"

/* Enable me to enable OpenMP support
#include <omp.h> */

void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {
    
    double *W, *Z, *E, *R, *N, rho;
    double *myW, *myZ, *myE, *myR;
    ptrdiff_t i, t, T, D;
    
    W = mxGetPr(prhs[0]);
    Z = mxGetPr(prhs[1]);
    E = mxGetPr(prhs[2]);
    R = mxGetPr(prhs[3]);
    rho = mxGetScalar(prhs[4]);
    N = mxGetPr(prhs[5]);
    D = mxGetM(prhs[0]);
    T = mxGetN(prhs[0]);
    
    /* Enable me to make use of OpenMP
    #pragma omp parallel for default(shared) private(t, myW, myZ, myE, myR, i) */
    for(t = 0; t < T; t++)
    {
        myW = W + D*t;
        myZ = Z + D*t;
        myE = E + D*t;
        myR = R + D*t;
        for(i = 0; i < D; i++)
            myW[i] = myR[i] + N[t]*(rho*myZ[i] - myE[i]);
    }
}