#include "mex.h"
#include "math.h"

void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {
    
    double *W, *Z, *E, *Zold, rho;
    double r, s, delta;
    ptrdiff_t i,j, N;
    
    W = mxGetPr(prhs[0]);
    Z = mxGetPr(prhs[1]);
    E = mxGetPr(prhs[2]);
    Zold = mxGetPr(prhs[3]);
    rho = mxGetScalar(prhs[4]);
    N = mxGetM(prhs[0])*mxGetN(prhs[0]);
    
    r = 0;
    s = 0;
    for(i = 0; i < N; i++)
    {
        delta = W[i] - Z[i];
        E[i] += rho*delta;
        delta = fabs(delta);
        r = r > delta ? r : delta;
        delta = fabs(Z[i] - Zold[i]);
        s = s > delta ? s : delta;
    }
    
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
    W = mxGetPr(plhs[0]);
    W[0] = r;
    W = mxGetPr(plhs[1]);
    W[0] = rho*s;
}