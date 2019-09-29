#include "mex.h"
#include "blas.h"
#include "lapack.h"
/*Declare constants for BLAS libraries*/
double oned = 1;
double noned = -1;
double zerod = 0;
ptrdiff_t one = 1;
char Nc = 'N';
char tc = 't';
char Uc = 'U';

void AssignZero(double *a, ptrdiff_t n)
{
    int i;
    for(i = 0; i < n; i++)
        a[i] = 0;
}
void ComputeEpsilon(double *U, double *G3, double *epsilon, double *Uepsilon, int32_T *indices, ptrdiff_t n, ptrdiff_t D)
{
    ptrdiff_t i;
    /*epsilon = U*Uepsilon*/
    for(i = 0; i < n; i++)
        epsilon[i] = ddot(&D, U + D*indices[i], &one, Uepsilon, &one);
    /*G3\(G3'\epsilon)*/
    dpotrs(&Uc, &n, &one, G3, &n, epsilon, &n, &i);
    /*Uepsilon = U'*epsilon*/
    for(i = 0; i < D; i++)
        Uepsilon[i] = 0;
    for(i = 0; i < n; i++)
        daxpy(&D, epsilon + i, U + D*indices[i], &one, Uepsilon, &one);
}


void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {
    
    ptrdiff_t T, i, D, task;
    double *tid, *Uepsilon, *U, *size;
    const mxArray *epsilon, *missing, *G3;
    
    tid = mxGetPr(prhs[0]);
    T = mxGetM(prhs[0])*mxGetN(prhs[0]);
    U = mxGetPr(prhs[1]);
    D = mxGetM(prhs[1]);
    G3 = prhs[2];
    epsilon = prhs[3];
    Uepsilon = mxGetPr(prhs[4]);
    missing = prhs[5];
    size = mxGetPr(prhs[6]);
    
    for(i = 0; i < T; i++)
    {
        task = ((ptrdiff_t)tid[i]) - 1;
        if(size[i] == 0)
            AssignZero(Uepsilon+D*i, D);
        else
            ComputeEpsilon(U, mxGetPr(mxGetCell(G3, task)), 
                    mxGetPr(mxGetCell(epsilon, task)), Uepsilon + D*i, (int32_T*)mxGetData(mxGetCell(missing, task)), 
                    (ptrdiff_t)size[task], D);
    }
}