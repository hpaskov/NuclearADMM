#include "mex.h"
#include "blas.h"

/* Enable me to enable OpenMP support
#include <omp.h> */

double oned = 1;
double noned = -1;
double zerod = 0;
ptrdiff_t one = 1;
char Nc = 'N';
char tc = 't';
char Uc = 'U';

void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {
    
    double *W, *V, *epsilon, *N, rho, q;
    ptrdiff_t t, D, start, end, n;
    
    W = mxGetPr(prhs[0]);
    V = mxGetPr(prhs[1]);
    epsilon = mxGetPr(prhs[2]);
    rho = mxGetScalar(prhs[3]);
    N = mxGetPr(prhs[4]);
    start = (ptrdiff_t)mxGetScalar(prhs[5]) - 1;
    end = (ptrdiff_t)mxGetScalar(prhs[6]);
    D = mxGetM(prhs[0]);
    n = mxGetM(prhs[2]);
    
    /* Enable me to make use of OpenMP
    #pragma omp parallel for default(shared) private(t, q) */
    for(t = start; t < end; t++)
    {
        q = 1.0/(rho*N[t]);
        dscal(&D, &q, W + D*t, &one);
    }
    end -= start;
    dgemm(&Nc, &Nc, &D, &end, &n, &oned, V, &D, epsilon, &n, &oned, W + D*start, &D);
}